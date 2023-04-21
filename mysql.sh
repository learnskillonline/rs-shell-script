source common.sh
mysql_pass=$1
if [ -z "${mysql_pass}" ]; then
  echo "Enter mysql password along with script"
  exit 1
fi
print_head "disabling default mysql"
dnf module disable mysql -y
print_head "copying mysql repo"
cp ${code_dir}/Config/mysql.repo /etc/yum.repos.d/mysql.repo

print_head "installing mysql 5.7"
yum install mysql-community-server -y

print_head "enabling and restarting mysql server"
systemctl enable mysqld
systemctl restart mysqld

mysql_secure_installation --set-root-pass ${mysql_pass}