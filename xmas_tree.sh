#!/usr/bin/env bash
#
# Create a christmas tree with many twinkling stars on the terminal
#
# Author: Dave Eddy <dave@daveeddy.com>
# Modified by: James Mascarenhas
# License: MIT

# colors
color_tree=$(tput setaf 2)
color_star=$(tput setaf 227)   # Golden star
color_twinkle=$(tput setaf 15)  # Bright white for twinkling stars

# lights - dave matched these to "vintaglo vintage christmas lights"
color_lights=(
	"$(tput setaf 111)"
	"$(tput setaf 208)"
	"$(tput setaf 198)"
	"$(tput setaf 155)"
)
len=${#color_lights[@]}

# the tree itself - each number represents a specific "light" color
IFS= read -r -d '' TREE <<-"EOF"
                  *
                 / \
                / 0 \
               / 1   \
              /       \
             /_ 2  1  _\
              /       \
             /  1   2  \
            /           \
           /   0  3  0   \
          /_        1    _\
           /    2        \
          /  1   0   0    \
         /    3         3  \
        /  2        1       \
        ---------------------
                 |||
                /|||\
EOF
TREE_HEIGHT=18

MESSAGE=(
	"${color_lights[3]}Merry Christmas Noodles!"
	"${color_lights[3]}From James"
	"${color_lights[1]}$ ${color_lights[0]}curl jamesmascarenhas.sh"
)

# configure terminal for drawing
cleanup() {
	tput rmcup
	tput cnorm
}
trap cleanup EXIT
tput smcup
tput civis

# figure out our size
COLS=$(tput cols)
LINES=$(tput lines)
middle_y=$((LINES / 2 - (TREE_HEIGHT / 2)))

# dynamically generate random star positions around the tree
generate_star_positions() {
    star_positions=()
    for _ in {1..100}; do  # Generate 100 stars
        while true; do
            rand_y=$((RANDOM % LINES))  # Random Y position within terminal height
            rand_x=$((RANDOM % COLS))   # Random X position within terminal width

            # Ensure the star does not overlap the tree or the message
            if ((rand_y >= middle_y && rand_y <= middle_y + TREE_HEIGHT)) &&
               ((rand_x >= COLS / 2 - 10 && rand_x <= COLS / 2 + 10)); then
                continue
            elif ((rand_y >= middle_y + 7 && rand_y <= middle_y + 10)) &&
                 ((rand_x >= COLS / 2 - 10 && rand_x <= COLS / 2 + 30)); then
                continue
            fi

            # Add star position if valid
            star_positions+=("$rand_y $rand_x")
            break
        done
    done
}

# current color index
generate_star_positions
idx=0
while true; do
	# stylize and colorize tree
	t=$color_tree$TREE
	t=${t// \*/ ${color_star}*${color_tree} }  # Golden star at the top
	t=${t// 0 / ${color_lights[idx % len]}o${color_tree} }
	t=${t// 1 / ${color_lights[(idx + 1) % len]}o${color_tree} }
	t=${t// 2 / ${color_lights[(idx + 2) % len]}o${color_tree} }
	t=${t// 3 / ${color_lights[(idx + 3) % len]}o${color_tree} }

	# display the tree
	tput cup "$middle_y" $((COLS / 2 - 10))
	echo "$t"

	# display the twinkling stars
	for pos in "${star_positions[@]}"; do
		star_y=$(echo "$pos" | cut -d' ' -f1)
		star_x=$(echo "$pos" | cut -d' ' -f2)

		if ((RANDOM % 2 == 0)); then
			# Show a twinkling star
			tput cup "$star_y" "$star_x"
			echo -n "${color_twinkle}*"
		else
			# Clear the position
			tput cup "$star_y" "$star_x"
			echo -n " "
		fi
	done

	# display the text
	y=$((middle_y + 7))
	for line in "${MESSAGE[@]}"; do
		tput cup "$y" $((COLS / 2 - 10))
		echo "$line"
		((y++))
	done

	# increment the lights and pause for the animation to play
	((idx++))

	# Regenerate star positions occasionally to vary the twinkling
	if ((idx % 10 == 0)); then
		generate_star_positions
	fi

	sleep 0.4
done
