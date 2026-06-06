\# 1. INSTALL OPTIPNG \& WEBP TOOLS

\# For UbuntuDebian

sudo apt update \&\& sudo apt install optipng webp -y



\# 2. CREATE OPTIMIZATION SCRIPT

\# Save this to usrlocalbinoptimize-pngs.sh

\#!binbash

WEB\_ROOT=varwwwhtml



\# Optimize PNGs modified in the last 60 mins (Lossless)

find $WEB\_ROOT -mmin -60 -name .png -print0  xargs -0 optipng -o5 -strip all -quiet -preserve



\# Create WebP versions for better compression (LossyModern)

find $WEB\_ROOT -mmin -60 -name .png -exec sh -c 'cwebp -q 80 $1 -o ${1%.png}.webp' \_ {} ;



\# 3. SET PERMISSIONS

sudo chmod +x usrlocalbinoptimize-pngs.sh



\# 4. AUTOMATE WITH CRONTAB

\# Run 'crontab -e' and add this line to run every hour

0     usrlocalbinoptimize-pngs.sh



\# 5. NGINX CONFIGURATION (Caching \& WebP Delivery)

\# Add to your server block

```TEXT

\# location \~ .(pngwebp)$ {

\#     # Serve WebP if browser supports it and file exists

\#     add\_header Vary Accept;

\#     try\_files $uri.webp $uri =404;

\# 

\#     # Cache instructions

\#     expires 30d;

\#     add\_header Cache-Control public, no-transform;

\#     access\_log off;

\# }

```

