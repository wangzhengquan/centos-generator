genisoimage -U -r -v -T -J -joliet-long                                   \
            -V DEEPINOS -A DEEPINOS -volset DEEPINOS                      \
            -c isolinux/boot.cat    -b isolinux/isolinux.bin              \
            -no-emul-boot -boot-load-size 4 -boot-info-table              \
            -eltorito-alt-boot -e images/efiboot.img -no-emul-boot        \
            -o  centos7-server-custom-install.iso                       \
            iso-temp
implantisomd5  centos6-server-custom-install.iso