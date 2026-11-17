# lib/ProxyHelper.pl
# Automated Apache and Nginx reverse proxy configuration for Virtualmin domains
package VirtualminWebApps::ProxyHelper;

use strict;
use warnings;

# setup_reverse_proxy($domain_ref, $app_name, $local_port, $enable_websocket, [$custom_path])
# Sets up reverse proxy in Apache or Nginx for a Virtualmin domain
sub setup_reverse_proxy
{
    my ($d, $app_name, $port, $enable_websocket, $path) = @_;
    $path ||= '/';
    $path = "/$path" if $path !~ /^\//;
    $path =~ s/\/$// if $path ne '/';

    my $webserver = &detect_webserver($d);

    if ($webserver eq 'apache') {
        return &setup_apache_proxy($d, $app_name, $port, $enable_websocket, $path);
    }
    elsif ($webserver eq 'nginx') {
        return &setup_nginx_proxy($d, $app_name, $port, $enable_websocket, $path);
    }
    else {
        return (0, "Unknown or unsupported webserver for domain $d->{'dom'}");
    }
}

# remove_reverse_proxy($domain_ref, $app_name)
# Removes proxy directives added for the app
sub remove_reverse_proxy
{
    my ($d, $app_name) = @_;
    my $webserver = &detect_webserver($d);

    if ($webserver eq 'apache') {
        return &remove_apache_proxy($d, $app_name);
    }
    elsif ($webserver eq 'nginx') {
        return &remove_nginx_proxy($d, $app_name);
    }
    return 1;
}

# detect_webserver($d)
sub detect_webserver
{
    my ($d) = @_;
    if ($d->{'nginx'}) {
        return 'nginx';
    }
    return 'apache';
}

# setup_apache_proxy
sub setup_apache_proxy
{
    my ($d, $app_name, $port, $enable_websocket, $path) = @_;
    my $conf_file = &get_apache_conf_file($d);
    return (0, "Could not determine Apache configuration file for $d->{'dom'}") if !$conf_file || !-f $conf_file;

    # Read config
    my $content = &read_file_contents($conf_file);
    return (0, "Empty Apache configuration file: $conf_file") if !$content;

    # Remove existing block if present
    $content = &strip_block($content, $app_name);

    # Generate directive block
    my $block = "# BEGIN VIRTUALMIN WEBAPP: $app_name\n";
    $block   .= "ProxyPreserveHost On\n";
    $block   .= "ProxyRequests Off\n";
    $block   .= "RequestHeader set X-Forwarded-Proto expr=%{REQUEST_SCHEME}\n";

    if ($enable_websocket) {
        $block .= "RewriteEngine On\n";
        $block .= "RewriteCond %{HTTP:Upgrade} =websocket [NC]\n";
        $block .= "RewriteRule ^/(.*)           ws://127.0.0.1:$port/\$1 [P,L]\n";
        $block .= "RewriteCond %{HTTP:Upgrade} !=websocket [NC]\n";
    }

    if ($path eq '/') {
        $block .= "ProxyPass / http://127.0.0.1:$port/\n";
        $block .= "ProxyPassReverse / http://127.0.0.1:$port/\n";
    }
    else {
        $block .= "ProxyPass $path http://127.0.0.1:$port$path\n";
        $block .= "ProxyPassReverse $path http://127.0.0.1:$port$path\n";
    }
    $block .= "# END VIRTUALMIN WEBAPP: $app_name\n";

    # Insert before </VirtualHost> in SSL (port 443) or standard (port 80) blocks
    if ($content =~ /<\/VirtualHost>/i) {
        # Place it right before </VirtualHost>
        $content =~ s/(<\/VirtualHost>)/$block$1/g;
    } else {
        $content .= "\n$block\n";
    }

    &write_file_contents($conf_file, $content);
    &reload_webserver('apache');

    return (1, undef);
}

# remove_apache_proxy
sub remove_apache_proxy
{
    my ($d, $app_name) = @_;
    my $conf_file = &get_apache_conf_file($d);
    return 1 if !$conf_file || !-f $conf_file;

    my $content = &read_file_contents($conf_file);
    my $new_content = &strip_block($content, $app_name);

    if ($new_content ne $content) {
        &write_file_contents($conf_file, $new_content);
        &reload_webserver('apache');
    }
    return 1;
}

# setup_nginx_proxy
sub setup_nginx_proxy
{
    my ($d, $app_name, $port, $enable_websocket, $path) = @_;
    my $conf_file = &get_nginx_conf_file($d);
    return (0, "Could not determine Nginx configuration file for $d->{'dom'}") if !$conf_file || !-f $conf_file;

    my $content = &read_file_contents($conf_file);
    return (0, "Empty Nginx configuration file: $conf_file") if !$content;

    $content = &strip_block($content, $app_name);

    my $loc = ($path eq '/') ? '/' : "$path/";
    my $block = "# BEGIN VIRTUALMIN WEBAPP: $app_name\n";
    $block   .= "    location $loc {\n";
    $block   .= "        proxy_pass http://127.0.0.1:$port;\n";
    $block   .= "        proxy_set_header Host \$host;\n";
    $block   .= "        proxy_set_header X-Real-IP \$remote_addr;\n";
    $block   .= "        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;\n";
    $block   .= "        proxy_set_header X-Forwarded-Proto \$scheme;\n";

    if ($enable_websocket) {
        $block .= "        proxy_http_version 1.1;\n";
        $block .= "        proxy_set_header Upgrade \$http_upgrade;\n";
        $block .= "        proxy_set_header Connection \"upgrade\";\n";
    }

    $block .= "    }\n";
    $block .= "# END VIRTUALMIN WEBAPP: $app_name\n";

    # Insert inside server { ... } block
    if ($content =~ /(server\s*\{)/) {
        $content =~ s/(server\s*\{)/$1\n$block/;
    } else {
        $content .= "\n$block\n";
    }

    &write_file_contents($conf_file, $content);
    &reload_webserver('nginx');

    return (1, undef);
}

# remove_nginx_proxy
sub remove_nginx_proxy
{
    my ($d, $app_name) = @_;
    my $conf_file = &get_nginx_conf_file($d);
    return 1 if !$conf_file || !-f $conf_file;

    my $content = &read_file_contents($conf_file);
    my $new_content = &strip_block($content, $app_name);

    if ($new_content ne $content) {
        &write_file_contents($conf_file, $new_content);
        &reload_webserver('nginx');
    }
    return 1;
}

sub strip_block
{
    my ($text, $app_name) = @_;
    $text =~ s/# BEGIN VIRTUALMIN WEBAPP: $app_name.*?# END VIRTUALMIN WEBAPP: $app_name\n?//gs;
    return $text;
}

sub get_apache_conf_file
{
    my ($d) = @_;
    # Try Virtualmin's metadata
    return $d->{'apache_conf'} if $d->{'apache_conf'} && -f $d->{'apache_conf'};

    # Common locations on Debian/Ubuntu and RHEL/Fedora
    my @candidates = (
        "/etc/apache2/sites-available/$d->{'dom'}.conf",
        "/etc/apache2/sites-enabled/$d->{'dom'}.conf",
        "/etc/httpd/conf.d/$d->{'dom'}.conf",
        "/etc/apache2/conf.d/$d->{'dom'}.conf"
    );
    foreach my $c (@candidates) {
        return $c if -f $c;
    }
    return undef;
}

sub get_nginx_conf_file
{
    my ($d) = @_;
    return $d->{'nginx_conf'} if $d->{'nginx_conf'} && -f $d->{'nginx_conf'};

    my @candidates = (
        "/etc/nginx/sites-available/$d->{'dom'}.conf",
        "/etc/nginx/sites-enabled/$d->{'dom'}.conf",
        "/etc/nginx/conf.d/$d->{'dom'}.conf"
    );
    foreach my $c (@candidates) {
        return $c if -f $c;
    }
    return undef;
}

sub reload_webserver
{
    my ($srv) = @_;
    if ($srv eq 'apache') {
        system("systemctl reload apache2 2>/dev/null || systemctl reload httpd 2>/dev/null");
    } elsif ($srv eq 'nginx') {
        system("systemctl reload nginx 2>/dev/null");
    }
}

sub read_file_contents
{
    my ($file) = @_;
    open(my $fh, '<', $file) or return undef;
    local $/;
    my $content = <$fh>;
    close($fh);
    return $content;
}

sub write_file_contents
{
    my ($file, $content) = @_;
    open(my $fh, '>', $file) or return 0;
    print $fh $content;
    close($fh);
    return 1;
}

1;
