code_dir=$(pwd)
yum install nginx -y
systemctl enable nginx
systemctl start nginx
rm -rf /usr/share/nginx/html/*
curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend.zip
cd /usr/share/nginx/html
unzip /tmp/frontend.zip
cp ${code_dir}/configs/frontend.conf /etc/nginx/default.d/roboshop.conf
systemctl restart nginx
echo -e "\e[32mLOOKS EVERYTHING WENT FINE\e["