#!/bin/bash

for vm in $(VBoxManage list runningvms | awk '{print $2}' | tr -d '{}'); do
    VBoxManage controlvm "$vm" poweroff
done

for vm in $(VBoxManage list vms | awk '{print $2}' | tr -d '{}'); do
    VBoxManage closemedium disk "$vm" --delete || echo "Brak blokady dla $vm"
done


for vm in $(VBoxManage list vms | awk '{print $2}' | tr -d '{}'); do
    VBoxManage unregistervm "$vm" --delete || echo "Nie udało się usunąć $vm, może być nadal zablokowany"
done

VBoxManage list vms
terraform destroy -auto-approve

echo "Operacja zakończona."
