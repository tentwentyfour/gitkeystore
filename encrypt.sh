#!/bin/bash

###
#
# Encrypt files for safe storage
# @license: GPL v3
# @author David Raison <david@tentwentyfour.lu>
#
# Limitations: Currently, this works for 3 people only ;)
#
##

# In order to be able to select which keys to encrypt for, we need to offer a list to the user

indices=( 1 2 4 )
people=( John Paul Ringo )
keys=( 29BC77C4 35EA1723 CDE59276 )
selection=0


invalid() {
    echo "That's an invalid entry, sorry! Permitted are only values 1 through 7"
    exit 1
}

usage() {
    echo "Usage: $0 [-a|-r index] file"
    exit 1
}


# If git is not configured correctly, bail out!
thisuser=$(git config user.email)
if [[ "${thisuser}" == "" ]]; then
    echo "You must have set user.email in your git config!";
	exit 1
fi

thiskey=$(gpg --list-keys ${thisuser} | awk '/^pub/ {print $2}' | awk -F/ '{print $2}')

for i in ${indices[@]}; do
    num=$((i + num));
done;

# Make sure last argument is an existing file
[[ -f ${@: -1} ]] || usage

while getopts "ar:" opt; do
    case ${opt} in
        a)
            echo "Encrypting for all keys!";
            selection=7
            shift
            ;;
        r)
            # Check that the argument to -r is not the last option on the command line
            [[ ${OPTARG} == ${@: -1} ]] && usage
            # Check that the argument to -r is inside the valid range
            (( ${OPTARG} <= $num )) || invalid
            selection=${OPTARG}
            # Make sure that we shift by the correct number of arguments
            # whether the option was specified as -r num or -rnum
            shift $((OPTIND - 1))
            ;;
    esac
done

# If neither -a nor -r was specified, prompt the user for a selection
if [ $selection -eq 0  ]; then
	echo "Encrypt for which keys?"
	for i in ${!keys[@]}; do
	    j=${indices[$i]}
	    echo "$j - ${keys[$i]} - ${people[$i]}";
	done
    echo "Add up values to combine keys. (e.g. 5 for John + Ringo)"
	read selection
fi


# Check that the user specified whom to encrypt for
if [ $selection -gt $num ]; then
    invalid
else
    # echo $(( $selection & 1 ))
    # echo $(( $selection & 3 ))
    # echo $(( $selection & 4 ))
    # echo $(( $selection & 7 ))

    # I'm certain there must be better way (see above), but hmm… that's for next time
    case $selection in
    1)
        val="-r ${keys[0]}";
        ;;
    2)
        val="-r ${keys[1]}";
        ;;
    3)
        val="-r ${keys[0]} -r ${keys[1]}";
        ;;
    4)
        val="-r ${keys[2]}";
        ;;
    5)
        val="-r ${keys[0]} -r ${keys[2]}";
        ;;
    6)
        val="-r ${keys[1]} -r ${keys[2]}";
        ;;
    7)
        val="-r ${keys[0]} -r ${keys[1]} -r ${keys[2]}";
        ;;
    esac

	# Must be impossible not to select one's own key!
	if [[ "$val" =~ "$thiskey" ]]; then
		echo "Good, you didn't forget to include your own key ;)"
	else
		echo "Adding own key, lest we exclude ourselves!"
		val="${val} -r ${thiskey}"
	fi

    echo "Selected $val";
fi

gpg --yes -v --cipher-algo AES256 --digest-algo SHA512 ${val} -ase $1 && rm $1
