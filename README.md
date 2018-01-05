Как скачать себе пайплайн и заставить его работать:

0) На вашем компьютере должны быть установлены: git, snakemake, docker.

1) Скачайте snakefile (в нем описано какие программы и когда запускать) и основные папки: 
    > git clone https://github.com/FedotovaEvgenia/biopipeline.git \
    > cd biopipeline

2) Скачайте референсы и библиотеки (для hg38), без них пайплайн ничего не знает (придется скачать 12,3 GB):
    > curl http://my-area.ru/biopipeline/reference.tar.gz -o reference/reference.tar.gz \
    > tar -xvzf reference/reference.tar.gz

3) Задайте пайплайну входные данные - прямые и обратные риды в формате fastq.
* Если у вас нет своих данных, вы можете скачать наши (и ничего больше не менять):
     > curl http://my-area.ru/biopipeline/input.tar.gz -o input/input.tar.gz \
     > tar -xvzf input/input.tar.gz
* Если у вас есть свои данные, поместите их в папку input, например: my_reads_R1.fastq, my_reads_R2.fastq и создайте конфиг файл config.json. В config.json запишите:
     > { \
     >   "input_folder": "input/", \
     >   "read_name": "my_reads_R", \
     >   "output_folder": "output/" \
     > } 
     
     Наконец, убедитесь, что в Snakefile в первой строчке правильно указан путь до вашего config.json.

4) Все! Теперь можно запускать пайплайн: 
      > user@user-Desktop:/biopipeline$ snakemake 
      
   Результаты работы пайплайна будут в папке output. Конечный результат будет в подпапке freq_parser.
