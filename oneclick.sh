#!/bin/bash

# JSON ফাইল যেখানে টুলের ডেটা সংরক্ষিত
TOOLS_FILE="tools.json"

# টুল ইনস্টলেশনের ফাংশন
install_tool() {
    TOOL_NAME=$1
    TOOL_URL=$2

    echo -e "Installing $TOOL_NAME..."
    git clone "$TOOL_URL" || echo -e "Error installing $TOOL_NAME!"
}

# সেরা ২০ টুল ইনস্টল ফাংশন
install_top_20() {
    echo -e "\n[+] Installing Top 20 Tools...\n"
    jq -c '.top_20[]' "$TOOLS_FILE" | while read -r TOOL; do
        NAME=$(echo "$TOOL" | jq -r '.name')
        URL=$(echo "$TOOL" | jq -r '.url')
        install_tool "$NAME" "$URL"
    done
    echo -e "\n[+] All Top 20 Tools Installed Successfully!\n"
}

# সকল টুল ইনস্টল ফাংশন
install_all_tools() {
    echo -e "\n[+] Installing All Tools...\n"
    jq -c '.top_20[], .all_tools[]' "$TOOLS_FILE" | while read -r TOOL; do
        NAME=$(echo "$TOOL" | jq -r '.name')
        URL=$(echo "$TOOL" | jq -r '.url')
        install_tool "$NAME" "$URL"
    done
    echo -e "\n[+] All Tools Installed Successfully!\n"
}

# নির্দিষ্ট টুল ইনস্টল ফাংশন
install_selected_tools() {
    echo -e "\n[+] Installing Selected Tools...\n"
    IFS=',' read -ra TOOL_LIST <<< "$1"
    for TOOL_NAME in "${TOOL_LIST[@]}"; do
        TOOL=$(jq -c '.top_20[], .all_tools[] | select(.name=="'"$TOOL_NAME"'")' "$TOOLS_FILE")
        if [[ -n $TOOL ]]; then
            NAME=$(echo "$TOOL" | jq -r '.name')
            URL=$(echo "$TOOL" | jq -r '.url')
            install_tool "$NAME" "$URL"
        else
            echo "[-] Tool $TOOL_NAME not found in JSON file."
        fi
    done
    echo -e "\n[+] Selected Tools Installed Successfully!\n"
}

# টুল লিস্ট দেখানোর ফাংশন
list_tools() {
    echo -e "\n[+] Available Tools:\n"
    jq -r '.top_20[].name, .all_tools[].name' "$TOOLS_FILE"
}

# ব্যানার ফাংশন
show_banner() {
    echo -e "╔═╗╔╗╔╔═╗  ╔═╗╦  ╦╔═╗╦╔═"
    echo -e "║ ║║║║║╣───║  ║  ║║  ╠╩╗"
    echo -e "╚═╝╝╚╝╚═╝  ╚═╝╩═╝╩╚═╝╩ ╩"
    echo -e "..................[V1.0][@hackinter]\n\n"
    echo -e "Usage:\n"
    echo -e "./oneclick -i top-bughunt-tools [ to install top-bughunting-tools ]"
    echo -e "./oneclick -i toolname [ to install single tools ]"
    echo -e "./oneclick -i all [ to install all tools ]"
    echo -e "./oneclick -i list [ to list all tools ]"
    echo -e "./oneclick -b toolname,toolname [ to install multiple tools ]\n"
}

# হেল্প ফাংশন
usage() {
    show_banner
    exit 1
}

# স্ক্রিপ্ট কমান্ড লাইন প্যারামিটার প্রসেস
if [[ "$#" -eq 0 ]]; then
    usage
fi

while getopts ":i:b:l" opt; do
    case $opt in
        i)
            if [[ "$OPTARG" == "top-bughunt-tools" ]]; then
                install_top_20
            elif [[ "$OPTARG" == "all" ]]; then
                install_all_tools
            elif [[ "$OPTARG" == "list" ]]; then
                list_tools
            else
                install_selected_tools "$OPTARG"
            fi
            ;;
        b)
            install_selected_tools "$OPTARG"
            ;;
        l)
            list_tools
            ;;
        *)
            usage
            ;;
    esac
done
