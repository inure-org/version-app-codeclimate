require "spec_helper"

class CC::Workspace
    describe PathTree do
        include FileSystemHelpers

        MAX_FILTER_SECONDS = 10
        NUM_FILES = 50_000
        AVG_FILES_PER_DIR = 20
        REPO_DEPTH = 30
        NUM_EXCLUDES = 50

        it "performar aceitável" do
            within_temp_dir do
                make_files
                exclude_paths = make_exclude_paths

                elapsed = Benchmark.realtime do
                    tree = PathTree.for_path(".")
                    tree.exclude_paths(exclude_paths)
                    tree.all_paths
                end
                
                puts "pathtree acima de arquivos #{`find . -type f -print | wc -l`.strip}, nos quais #{exclude_paths.count} excluam took: #{elapsed}s"

                expect(elapsed).to be_between(0, MAX_FILTER_SECONDS)
            end
        end

        def make_files
            NUM_FILES.times do
                dir = dir_names[rand(dir_names.count)]

                begin
                    if dir.present?
                        make_file File.join(dir, rand_file_name)
                    else
                        make_file rand_file_name
                    end
                rescue Errno::EEXIST, Errno::EISDIR
                    # nada :p
                end
            end
        end

        def dir_names
            # nil é para o root do projeto, adicionar bunch para outros diretórios
            @dir_names ||= [nil] + (NUM_FILES / AVG_FILES_PER_DIR).times.collect do
                File.join(rand(REPO_DEPTH).times.collect { rand_file_name })
            end
        end

        def rand_file_name
            SecureRandom.hex(rand(16) + 1)
        end

        def make_exclude_paths
            NUM_EXCLUDES.times.collect do
                base_dir = dir_names[rand(dir_names.count + 1)]

                next unless base_dir.present?

                case rand(3)
                when 0 # sem mudanças: excluir o diretório
                    base_dir
                when 1 # se o diretório possuir tamanho apropriado, adicionr /**/*, caso contrário, sem mudanças
                    pieces = base_dir.split(File::SEPARATOR)

                    if pieces.count > (REPO_DEPTH / 10) && pieces.count < REPO_DEPTH
                        File.join(base_dir, "**", "*")
                    else
                        base_dir
                    end
                when 2 # reposicionar aleatoriamente os bits dos diretórios com * para forçar matching glob
                    pieces = base_dir.split(File::SEPARATOR)

                    if pieces.count > (REPO_DEPTH / 10) && pieces.count < REPO_DEPTH
                        File.join(pieces.map do |piece|
                            if rand(100) > 65
                                piece[0..(1 + rand(piece[0].length))] + "*"
                            else
                                piece
                            end)
                        else
                            base_dir
                        end
                    end
                end.reject(&:nil?)
            end
        end
    end
end
