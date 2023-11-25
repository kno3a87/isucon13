#!/bin/bash

# 引数で渡されたブランチ名を変数に格納、もしくはデフォルトの 'main' を使用
BRANCH_NAME=${1:-master}

git fetch
# ブランチに切り替える
git switch $BRANCH_NAME

# スクリプトの実行結果を出力
if [ $? -eq 0 ]; then
  echo "Successfully switched to branch '$BRANCH_NAME'"
else
  echo "Failed to switch to branch '$BRANCH_NAME'"
  exit 1
fi

git pull origin $BRANCH_NAME

cd go

# アプリケーションの再起動
# ここは環境に合わせて調整する
echo "Restart Application..."
make build
sudo systemctl restart isupipe-go.service


# access log をリセット & nginx 再起動
echo "Restart Nginx..."
sudo cp /dev/null /var/log/nginx/access.log
sudo systemctl restart nginx.service

# slow query のリセット & mysql 再起動
echo "Restart MySQL..."
sudo cp /dev/null /var/log/mysql/mysql-slow.log
sudo systemctl restart mysql.service

git switch -
cd ..
