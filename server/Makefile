SRC = ./proto

generate:
	for f in $(shell find $(SRC) -name '*.proto'); do \
	  base=$$(basename $$f .proto); \
	  dir=$$(dirname $$f); \
	  out_dir=$$dir/$${base}pb; \
	  mkdir -p $$out_dir; \
	  protoc --go_out=. --go-grpc_out=. \
			--go_opt=paths=source_relative \
			--go-grpc_opt=paths=source_relative $$f; \
	  mv $$dir/$${base}.pb.go $$out_dir/; \
		[ -f "$$dir/$${base}_grpc.pb.go" ] && \
	  	mv $$dir/$${base}_grpc.pb.go $$out_dir/ || true; \
	done
	cd services/yt-scraper && bun run protoc:generate
