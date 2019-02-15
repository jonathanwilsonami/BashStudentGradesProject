{
	if(length($2) < 2) sec="00"$2       
	else if(length($2) < 3)sec="0"$2
	else sec=$2
	print $1,sec               
}
