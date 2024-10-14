#!/bin/bash

###########
## Lexur ##
###########

domain_validator() {
    local domain=$1

    if [[ $domain =~ ^([a-zA-Z0-9-]+\.)+[a-zA-Z]{2,}$  ]]; then
        return 0 # Valid
    else
        return 1 # Invalid
    fi
}

sudo apt update
# select "Internet Site"
sudo apt install dialog postfix postfix-mysql dovecot-core dovecot-imapd dovecot-sieve dovecot-lmtpd dovecot-mysql opendkim spamassassin spamc mariadb-server -y

whcih opendkim-genkey > /dev/null 2>&1 || sudo apt install opendkim-tools

while true; do
    read -p "[Domain]: " domain

    if domain_validator "$domain"; then
        # Its ok
        echo -e "\e[32mDomain validated.\e[0m"
        break
    else
        echo -e "\e[31mInvalid domain format.\e[0m"
    fi
done

subdom=${MAIL_SUBDOM:-mail}
mail_full_domain="$subdom.$domain"
certdir="/etc/letsencrypt/live/$mail_full_domain"

[ ! -d "$certdir"  ] && certdir="$(dirname "$(certbot certificates 2>/dev/null | grep "$mail_full_domain\|*.$domain" -A 2 | awk '/Certificate Path/ {print $3}' | head -n1)")"

[ ! -d "$certdir"  ] && echo "Note! You must first have a Let's Encrypt Certbot HTTPS/SSL Certificate for $mail_full_domain.

Use Let's Encrypt's Certbot to get that and then rerun this script.

You may need to set up a dummy $mail_full_domain site in nginx or Apache for that to work." && exit

echo -e "\e[32mConfiguring MySQL\e[0m"
echo -e "\e[32mLeave current password empty
Select no for set root password
Remove anonymous users
Disallow root login remotely
Remove test database and access to it
Reload privilege tables now\e[0m"
mysql_secure_installation

echo "\e[32mCreating database\e[0m"
name=$(dialog --inputbox "Please enter a name for the first email address.\\nEx. maik" 10 60 3>&1 1>&2 2>&3 3>&1) || exit 1
