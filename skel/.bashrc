#
# ~/.bashrc
#

alias vi='nvim'
alias sudo='sudo '

export SSH_AUTH_SOCK=/run/user/1000/keyring/ssh
export EDITOR='nvim'

alias sway='env XDG_CURRENT_DESKTOP=sway GTK_IM_MODULE=kime QT_IM_MODULE=kime XMODIFIERS=@im=kime sway'

#-----arch-powrline---($ sudo pacman -S powerline --needed)
#powerline-daemon -q
#POWERLINE_BASH_CONTINUATION=1
#POWERLINE_BASH_SELECT=1
#. /usr/share/powerline/bindings/bash/powerline.sh
#-----arch-powrline-----
# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
#PS1='[\u@\h \W]\$ '
PS1='[\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]]\$ '


#alias testc='gcc -o test *.c -std=c11 -Wextra -Wpedantic -pthread -pipe `pkg-config --cflags --libs gtk+-3.0` -export-dynamic -lmysqlclient;./test'
#sshcon 보다 편하게 ssh 접속을 위한 명령어 입니다.
#bakweb 지정된 웹 경로의 파일들을 백업하는 명령어 입니다.
#bakdb 지정된 DB아이디에 해당하는 데이터베이스를 백업하는 명령어 입니다.(MySQL,MariaDB 전용)
#bakall 위 두개의 백업 기능을 한번에 실행하는 명령어 입니다.
#사용법 : 터미널 창에서 $ sshcon 엔터

alias sshcon='ssh 접속아이디@접속주소'
alias bakweb='scp -r 접속아이디@접속주소:~/www ~/; tar -zcvf ~/$(date +%y%m%d)-bakweb.tgz ~/웹경로; rm -rf ~/웹경로'
alias bakdb='ssh 접속아이디@접속주소 mysqldump -u디비아이디 > $(date +%y%m%d).sql; tar -zcvf $(date +%y%m%d)-db.tgz $(date +%y%m%d).sql; rm $(date +%y%m%d).sql'
alias bakall='bakweb; bakdb'

#alias tmux1='tmux new -d;tmux split-pane -h;tmux split-pane -v;tmux select-pane -t 0;tmux attach'
#alias tmux1='tmux new -d;tmux splitp -h;tmux splitp -v;tmux selectp -t 0;tmux attach'

#alias vit='tmux new -d;tmux send-keys "vi" C-m;tmux splitp -v;tmux resizep -D 20;tmux splitp -h;tmux selectp -t 0;tmux attach'

function r() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}
