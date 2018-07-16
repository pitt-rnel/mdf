#!//bin/bash
#
# import all minimized record in mongodb test database
#
# by: Max Novelli
#     man8@pitt.edu
#     2018/06/26
#  

for file in `ls ../minimized/record?.json`; do 
  mongoimport --host 127.0.0.1 --port 15213 --db mdfDbTest --collection mdfDbTest --mode upsert < $file; 
done
