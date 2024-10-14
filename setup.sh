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
sudo apt install dialog postfix postfix-mysql dovecot-core dovecot-imapd dovecot-sieve dovecot-lmtpd dovecot-mysql opendkim spamassassin spamc mariadb-server

whcih opendkim-genkey > /dev/null 2>&1 || sudo apt install opendkim-tools

while true; do
    read -p "[Domain]: " domain

    if domain_validator "$domain"; then
        # Its ok
        echo -e "\e[32m]Domain validated.\e[0m]"
        break
    else
        echo -e "\e[31m]Invalid domain format.\e[0m]"
    fi
done

subdom=${MAIL_SUBDOM:-mail}
mail_full_domain="$subdom.$domain"
certdir="/etc/letsencrypt/live/$mail_full_domain"

[ ! -d "$certdir"  ] && certdir="$(dirname "$(certbot certificates 2>/dev/null | grep "$mail_full_domain\|*.$domain" -A 2 | awk '/Certificate Path/ {print {}' | head -n1)")"'}')")"

[ ! -d "$certdir"  ] && echo "Note! You must first have a Let's Encrypt Certbot HTTPS/SSL Certificate for $maildomain.

Use Let's Encrypt's Certbot to get that and then rerun this script.

You may need to set up a dummy $maildomain site in nginx or Apache for that to work." && exit

