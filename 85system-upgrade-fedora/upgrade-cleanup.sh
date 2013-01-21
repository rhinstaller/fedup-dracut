#!/bin/sh
getargbool 0 rd.upgrade.test && return # skip cleanup if we were just testing
chroot $NEWROOT fedup-cli --clean
cat << '__BEEFYMIRACLE__'
               .---. __
    ,         /     \   \    ||||
   \\\\      |O___O |    | \\||||
   \   //    | \_/  |    |  \   /
    '--/----/|     /     |   |-'
           // //  /     -----'
          //  \\ /      /
         //  // /      /
        //  \\ /      /
       //  // /      /
      /|   ' /      /
      //\___/      /
     //   ||\     /
     \\_  || '---'
     /' /  \\_.-
    /  /    --| |
    '-'      |  |
              '-'
__BEEFYMIRACLE__
