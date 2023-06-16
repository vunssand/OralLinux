#!/bin/bash

if ! command -v testdisk &>/dev/null; then
    sudo apt install testdisk -y
fi

afficherDisques() {
    echo "Disques durs disponibles :"
    fdisk -l # | grep -oE '/dev/[sh]d[a-z]' 
}

validationDisque() {
    local disque="$1"
    if [[ ! -b $disque ]]; then
        echo "Chemin vers le disque dur introuvable, veuillez réessayer"
        return 1
    fi
}

validationDossierSortie(){
    local dossierSortie="$1"
    if [[ ! -d $dossierSortie ]]; then
        echo "Chemin de sortie introuvable, veuillez réessayer"
        return 1
    fi
}

creationDossiersSortie(){
    local dossierSortie="$1"
    mkdir -p "$dossierSortie/videos"
    mkdir -p "$dossierSortie/images"
    mkdir -p "$dossierSortie/autres"
}

afficherDisques

while true; do
    echo "---------------------------------------------------"
    read -p "Entrez le chemin du disque dur à analyser (ex: /dev/sdA par défaut) : " disque
    if validationDisque "$disque"; then
        echo "Selection : $disque"
        break
    fi
done

while true; do
    read -p "Entrez le chemin du dossier de sortie (ex: /home/<nom d'utilisateur>/Desktop pour le bureau) : " dossierSortie
    if validationDossierSortie "$dossierSortie"; then
        echo "Selection : $dossierSortie"
        break
    fi
done

creationDossiersSortie "$dossierSortie"

# sudo testdisk /cmd "$disque"
sudo photorec /cmd /d "$dossierSortie"

function mvfiles() {
    local files_vid=$(find "$dossierSortie" -type f -iname ".mp4" -o -iname ".mov")
    local files_img=$(find "$dossierSortie" -type f -iname ".jpeg" -o -iname ".png" -o -iname ".jpg")

     if [[ ${#files_vid[@]} -eq 0 ]]; then
        for file in "${files_vid[@]}"; do
            mv $file "$dossierSortie/videos"
        done
    elif [[ ${#files_img[@]} -eq 0 ]]; then
        for file in "${files_img[@]}"; do
            mv $file "$dossierSortie/images"
        done
    else
        mv "*.*" "$dossierSortie/autres"
    fi
}