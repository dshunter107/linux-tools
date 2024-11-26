debug=0
print_option=1

source=$(pwd)

find $source -regextype sed -regex ".*Kconfig" > /tmp/kconfigs.txt
source_length=$((${#source}+1))

total_def_bool=0
total_def_tri=0
total_default=0

function print_line_number() {
	full_fn=$1
	line_number=$2
	def_type=$3
	fn=${full_fn:$source_length}
	
	if [ $print_option -eq 1 ]; then
		echo "$def_type $fn:$line_number" >> /tmp/defaults_found
	fi
}

while read line ; do
    i=0
    c=0
    d=0
    last=-2
    def_bool=0
    def_tri=0
    default=0
    while read ln ; do
	    i=$((i+1))
        if [[ "$ln" =~ "config" ]]; then
		c=$((c+1))
		last=$i	
        fi

	if [ $i -eq $((last+1)) ]; then 
		def_found=0
		def_type=""
		if [[ "$ln" =~ "def_bool" ]]; then
			def_bool=$((def_bool + 1))
			def_found=1
			def_type="def_bool "
		fi	
		if [[ "$ln" =~ "def_tristate" ]]; then
			def_tri=$((def_tri + 1))
			def_found=1
			def_type="def_tristate "
		fi	
		if [[ "$ln" =~ "default" ]]; then
			default=$((default + 1))
			def_found=1
			def_type="default "
		fi	
		if [ $def_found -eq 1 ]; then 
			print_line_number $line $i $def_type
		fi
	fi
    done <$line
    
    total_def_bool=$(($total_def_bool+$def_bool))
    total_def_tri=$(($total_def_tri+$def_tri))
    total_default=$(($total_default+$default))

    if [ $debug -eq 1 ]; then 
		echo "lines found in $line: $i"
		echo "configs found in $line: $c"
		echo "def_bools found $line: $def_bool"
		echo "def_tristates found $line: $def_tri"
		echo "defaults found $line: $default"
		echo ""
    fi
done </tmp/kconfigs.txt

    echo "def_bools found $line: $total_def_bool"
    echo "def_tristates found $line: $total_def_tri"
    echo "defaults found $line: $total_default"
   
