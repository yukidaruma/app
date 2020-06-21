if [ -e .dev_override.env ]; then
  cat .env .dev_override.env > assets/.env;
else
  echo ".dev_override.env is not found."
  cp .env assets/.env;
fi
