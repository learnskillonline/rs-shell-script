source common.sh
print_head "installing nginx"
yum install nginx -y &>>${log_file}
status_check $?
print_head "enabling nginx"
systemctl enable nginx &>>${log_file}
status_check $?
print_head "removing old contents"
rm -rf /usr/share/nginx/html/* &>>${log_file}
status_check $?
print_head "downloading frontend contents"
curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend.zip &>>${log_file}
status_check $?
print_head "extracting into nginx directory"
cd /usr/share/nginx/html &>>${log_file}
unzip /tmp/frontend.zip &>>${log_file}

print_head "copying frontend components"
cp ${code_dir}/configs/frontend.conf /etc/nginx/default.d/roboshop.conf &>>${log_file}
print_head "restarting nginx"
systemctl restart nginx &>>${log_file}
