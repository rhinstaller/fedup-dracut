#!/bin/sh
getargbool 0 rd.upgrade.test && return # skip cleanup if we were just testing
[ "$UPGRADE_STATE" == failed ] && return # skip cleanup on failure
chroot $NEWROOT fedup --clean
cat << '__BEEFYMIRACLE__'
|               .---. __
|    ,         /     \   \    ||||
|   \\\\      |O___O |    | \\||||
|   \   //    | \_/  |    |  \   /
|    '--/----/|     /     |   |-'
|           // //  /     -----'
|          //  \\ /      /
|         //  // /      /
|        //  \\ /      /
|       //  // /      /
|      /|   ' /      /
|      //\___/      /
|     //   ||\     /
|     \\_  || '---'
|     /' /  \\_.-
|    /  /    --| |
|    '-'      |  |
|              '-'
__BEEFYMIRACLE__
