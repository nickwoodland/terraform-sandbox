#! /bin/bash
cat > index.html << EOF
<h1>Greetings, Mortal.</h1>
<p>DB Address: ${db_address} </p>
<p>DB Port ${db_port}</p> 
EOF

nohup busybox httpd -f -p 8080 &