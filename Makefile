WP_DATA = /home/mgamraou/data/wordpress
DB_DATA = /home/mgamraou/data/mariadb

all: up

up:
	@sudo mkdir -p $(WP_DATA)
	@sudo mkdir -p $(DB_DATA)
	cd srcs && docker compose up -d --build

down:
	cd srcs && docker compose down

clean:
	cd srcs && docker compose down -v

fclean:
	cd srcs && docker compose down --rmi all -v
	sudo rm -rf $(WP_DATA)
	sudo rm -rf $(DB_DATA)

re: fclean all

.PHONY: all up down clean fclean re
