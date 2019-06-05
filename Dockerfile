FROM ubuntu:19.04


RUN apt-get update && apt-get install -y openssh-server curl git gnupg2 npm fish htop 

RUN mkdir ~/.config
RUN mkdir ~/.config/fish

RUN echo 'alias v="nvim"' >> ~/.config/fish/config.fish
RUN echo 'alias vi="nvim +\"CocInstall 'coc-tsserver'\" +\"CocInstall 'coc-css'\""' >> ~/.config/fish/config.fish

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

RUN apt-get update 
RUN apt-get install -y neovim nodejs yarn

# install vim-plug
RUN curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

RUN mkdir ~/.config/nvim
RUN wget -O ~/.config/nvim/init.vim https://gist.githubusercontent.com/i5heu/ba199e6b9ce48473964f86389e754ae8/raw/238f76931918003f5a4bb2ed30a7a60f083f406f/init.vim

RUN nvim +"PlugInstall | qa!" 

# SSH
RUN mkdir /var/run/sshd
RUN echo 'root:1234' | chpasswd
RUN sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# SSH login fix. Otherwise user is kicked off after login
RUN sed -ri 's/^#?PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config

RUN mkdir /root/.ssh

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

ADD . /root/workdir
EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
