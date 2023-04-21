code_dir=$(pwd)
log_file=/tmp/roboshopshell.log
rm -f ${log_file}
status_check()
{
  if [ $1 -ne 0 ]; then
    echo "\e[31mFAILURE\e[0m"
    exit 1
  else
    echo "\e[32mSUCCESS\e[0m"
  fi
}
print_head()
{
  echo -e "\e[35m$1\e[0m"
}
NODEJS()
{
  print_head "downloading node repo and installing nodejs"
  curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>>${log_file}
  status_check $?
  yum install nodejs -y &>>${log_file}
  status_check $?

  ROBOSHOP_APP_SETUP

  print_head "installing node package manager"
  npm install &>>${log_file}
  status_check $?

  print_head "copying ${component} service file"
  cp ${code_dir}/config-files/${component}.service /etc/systemd/system/${component}.service &>>${log_file}
  status_check $?

  print_head "installing node package manager"
  npm install &>>${log_file}
}
SYSTEMD_FUNC()
{
  systemctl daemon-reload
  systemctl enable ${component}
  systemctl restart ${component}
}
SCHEMA_SETUP()
{
  if [ "${schema_type}" == "mongo" ]; then
      print_head "Copy MongoDB Repo File"
      cp ${code_dir}/configs/mongodb.repo /etc/yum.repos.d/mongodb.repo &>>${log_file}
      status_check $?

      print_head "Install Mongo Client"
      yum install mongodb-org-shell -y &>>${log_file}
      status_check $?

      print_head "Load Schema"
      mongo --host mongodb-dev.easydevops.online </app/schema/${component}.js &>>${log_file}
      status_check $?
  elif [ "${schema_type}" == "mysql" ]; then
      print_head "Install MySQL Client"
      yum install mysql -y &>>${log_file}
      status_check $?

      print_head "Load Schema"
      mysql -h mysql-dev.easydevops.online -uroot -p${mysql_pass} < /app/schema/shipping.sql &>>${log_file}
      status_check $?
  fi
}
ROBOSHOP_APP_SETUP()
{
  print_head "Adding user if not exists"
  id roboshop
  if [ $? -ne 0 ]
  then
  useradd roboshop
  fi
  print_head "adding app dir if not exists"
  if [ ! -d /app ];then
  mkdir /app
  fi
  print_head "removing old contents"
  rm -rf /app/*

  print_head "downloading and extracting ${component} files"
  curl -L -o /tmp/${component}.zip https://roboshop-artifacts.s3.amazonaws.com/${component}.zip
  cd /app
  unzip /tmp/${component}.zip
}
PYTHON() {

  print_head "Install Python"
  yum install python36 gcc python3-devel -y &>>${log_file}
  status_check $?

  ROBOSHOP_APP_SETUP

  print_head "Download Dependencies"
  pip3.6 install -r requirements.txt &>>${log_file}
  status_check $?

  # SystemD Function
  SYSTEMD_FUNC
}