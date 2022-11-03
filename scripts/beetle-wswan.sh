#!/bin/bash

##################################################################
# Created by Christian Haitian for use to easily update          #
# various standalone emulators, libretro cores, and other        #
# various programs for the RK3566 platform for various Linux     #
# based distributions.                                           #
# See the LICENSE.md file at the top-level directory of this     #
# repository.                                                    #
##################################################################

cur_wd="$PWD"
bitness="$(getconf LONG_BIT)"

	# Libretro beetle-wswan build
	if [[ "$var" == "beetle-wswan" || "$var" == "all" ]] && [[ "$bitness" == "64" ]]; then
	 cd $cur_wd
	  if [ ! -d "beetle-wswan-libretro/" ]; then
		git clone https://github.com/libretro/beetle-wswan-libretro.git
		if [[ $? != "0" ]]; then
		  echo " "
		  echo "There was an error while cloning the libretro git.  Is Internet active or did the git location change?  Stopping here."
		  exit 1
		 fi
		cp patches/beetle_wswan_patch* beetle-wswan-libretro/.
	  fi

	 cd beetle-wswan-libretro/
	 
	 beetle_wswan_patches=$(find *.patch)
	 
	 if [[ ! -z "$beetle_wswan_patches" ]]; then
	  for patching in beetle_wswan_patch*
	  do
		   patch -Np1 < "$patching"
		   if [[ $? != "0" ]]; then
			echo " "
			echo "There was an error while applying $patching.  Stopping here."
			exit 1
		   fi
		   rm "$patching" 
	  done
	 fi

	  make clean
	  make -j$(nproc)

	  if [[ $? != "0" ]]; then
		echo " "
		echo "There was an error while building the newest lr-beetle-wswan core.  Stopping here."
		exit 1
	  fi

	  strip mednafen_wswan_libretro.so

	  if [ ! -d "../cores64/" ]; then
		mkdir -v ../cores64
	  fi

	  cp mednafen_wswan_libretro.so ../cores64/.

	  gitcommit=$(git log | grep -m 1 commit | cut -c -14 | cut -c 8-)
	  echo $gitcommit > ../cores$(getconf LONG_BIT)/mednafen_wswan_libretro.so.commit

	  echo " "
	  echo "mednafen_wswan_libretro.so has been created and has been placed in the rk3566_core_builds/cores64 subfolder"
	fi
