#!/usr/bin/env bash
# Tomorrow Night Blue - Gnome Terminal color scheme install script
# https://github.com/ChrisKempson/Tomorrow-Theme

[[ -z "$PROFILE_NAME" ]] && PROFILE_NAME="Tomorrow Night Blue"
[[ -z "$PROFILE_SLUG" ]] && PROFILE_SLUG="tomorrow-night-blue"
[[ -z "$DCONF" ]] && DCONF=dconf
[[ -z "$UUIDGEN" ]] && UUIDGEN=uuidgen

dset() {
    local key="$1"; shift
    local val="$1"; shift

    if [[ "$type" == "string" ]]; then
        val="'$val'"
    fi

    "$DCONF" write "$PROFILE_KEY/$key" "$val"
}

# Because dconf still doesn't have "append"
dlist_append() {
    local key="$1"; shift
    local val="$1"; shift

    local entries="$(
        {
            "$DCONF" read "$key" | tr -d '[]' | tr , "\n" | fgrep -v "$val"
            echo "'$val'"
        } | head -c-1 | tr "\n" ,
    )"

    "$DCONF" write "$key" "[$entries]"
}

# Newest versions of gnome-terminal use dconf
if which "$DCONF" > /dev/null 2>&1; then
    # Check that uuidgen is available
    type $UUIDGEN >/dev/null 2>&1 || { echo >&2 "Requires uuidgen but it's not installed.  Aborting!"; exit 1; }

    [[ -z "$BASE_KEY_NEW" ]] && BASE_KEY_NEW=/org/gnome/terminal/legacy/profiles:

    if [[ -n "`$DCONF list $BASE_KEY_NEW/`" ]]; then
        if which "$UUIDGEN" > /dev/null 2>&1; then
            PROFILE_SLUG=`uuidgen`
        fi

        if [[ -n "`$DCONF read $BASE_KEY_NEW/default`" ]]; then
            DEFAULT_SLUG=`$DCONF read $BASE_KEY_NEW/default | tr -d \'`
        else
            DEFAULT_SLUG=`$DCONF list $BASE_KEY_NEW/ | grep '^:' | head -n1 | tr -d :/`
        fi

        DEFAULT_KEY="$BASE_KEY_NEW/:$DEFAULT_SLUG"
        PROFILE_KEY="$BASE_KEY_NEW/:$PROFILE_SLUG"

        # Copy existing settings from default profile
        $DCONF dump "$DEFAULT_KEY/" | $DCONF load "$PROFILE_KEY/"

        # Add new copy to list of profiles
        dlist_append $BASE_KEY_NEW/list "$PROFILE_SLUG"

        # Update profile values with theme options
        dset visible-name "'$PROFILE_NAME'"
        dset palette "['#000000','#ff9da4','#d1f1a9','#ffeead','#bbdaff','#ebbbff','#99ffff','#929593','#666666','#FF9DA4','#D1F1A9','#FFEEAD','#BBDAFF','#EBBBFF','#99FFFF','#ECEBEC']"
        dset background-color "'#002451'"
        dset foreground-color "'#FFFFFF'"
        dset bold-color "'#99FFFF'"
        dset bold-color-same-as-fg "false"
        dset cursor-colors-set "true"
        dset cursor-background-color "'#ffffff'"
        dset cursor-foreground-color "'#002451'"
        dset highlight-colors-set "true"
        dset highlight-background-color "'#003f8e'"
        dset highlight-foreground-color "'#ffffff'"
        dset use-theme-colors "false"
        dset use-theme-background "false"

        unset PROFILE_NAME
        unset PROFILE_SLUG
        unset DCONF
        unset UUIDGEN
        exit 0
    fi
fi
