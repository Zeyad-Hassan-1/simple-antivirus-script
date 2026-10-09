DIR = dir
MALICIOUS_DIR = malicious_dir
INTERVAL = 5

antivirus: pre-build
	./antivirusd.sh $(DIR) $(MALICIOUS_DIR) $(INTERVAL)

pre-build:
	mkdir -p $(MALICIOUS_DIR)

restore: pre-build
	./restore.sh $(DIR) $(MALICIOUS_DIR)