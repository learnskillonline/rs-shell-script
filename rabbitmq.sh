source common.sh
rabbitmq_user_pass=$1
if [ -z "${rabbitmq_user_pass}" ]; then
echo "Enter rabbitmq password along with script"
exit 1
fi
print_head "installing erlang repo"
curl -s https://packagecloud.io/install/repositories/rabbitmq/erlang/script.rpm.sh | sudo bash &>>${log_file}
status_check $?

print_head "installin erlang "
yum install erlang -y  &>>${log_file}
status_check $?

print_head "installing rabbitmq server repo"
curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | sudo bash &>>${log_file}
status_check $?

print_head "installing rabbitmq server"
yum install rabbitmq-server -y &>>${log_file}
status_check $?

print_head "enabling and starting rabbitmq server"
systemctl enable rabbitmq-server &>>${log_file}
status_check $?
systemctl start rabbitmq-server &>>${log_file}
status_check $?

print_head "adding user and password"
rabbitmqctl list_users | grep roboshop &>>${log_file} #here re-run fails because roboshop already exists so we are using a rabbitmqctl list_users displays users in it. so based on grep command we are searching for roboshop and if there dont add user. if not then add the user.
if [ $? -ne 0 ]; then
rabbitmqctl add_user roboshop ${rabbitmq_user_pass} &>>${log_file}
fi
status_check $?

print_head "setting user tags"
rabbitmqctl set_user_tags roboshop administrator &>>${log_file}
status_check $?

print_head "setting permissions for roboshop"
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>>${log_file}
status_check $?