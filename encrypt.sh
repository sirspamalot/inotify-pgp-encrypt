#!/usr/bin/env bash

have_tty()
{
    tty >/dev/null 2>&1
    return $?
}

say()
{
    if have_tty; then echo $@; return; fi
    logger -i -t GPG_AUTOENCRYPT $@
}

fromdir=/where/the/source/lies
todir=/where/the/destination/is

while true; do
    inotifywait -qre close_write $fromdir | while read dir event file
    do
        if [ "$event" == 'CLOSE_WRITE,CLOSE' ]
        then
    	    gpg --encrypt --recipient 'PGP name' --output "$todir/$file.gpg" "$fromdir/$file"
    	    say "File $fromdir/$file has been successfully encrypted to $todir/$file.gpg - origin deleted!"
    	    rm -f "$fromdir/$file"
        elif [ "$event" == 'DELETE' ]
        then
    	    say "File $fromdir/$file has been deleted"
        else
    	    say "Could not do anything with $fromdir/$file, sorry for that...."
        fi
    done
done
