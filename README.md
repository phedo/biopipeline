Как скачать себе пайплайн и заставить его работать:

0) На вашем компьютере должны быть установлены: git, snakemake, docker.

1) Скачайте snakefile (в нем описано какие программы и когда запускать) и основные папки: 
    > git clone https://github.com/FedotovaEvgenia/biopipeline.git \
    > cd biopipeline

2) Скачайте и распакуйте в папку reference/ [референсы и библиотеки](https://drive.google.com/file/d/10wQD2m9TBP8ILb9dcFFTuN_CTyS-hllq/view?usp=sharing) (для hg38). Без них пайплайн ничего не знает. Придется скачать 12,3 GB.

3) Задайте пайплайну входные данные - прямые и обратные риды в формате fastq.
* Если у вас нет своих данных, вы можете [скачать наши](https://drive.google.com/file/d/1_Ea_1Agu2mFAWkf3QtQkNTeA_qyDSAdT/view?usp=sharing) (и ничего больше не менять).
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
   
---
Используемые в пайплайне Dockerfile и некоторые дистрибутивы доступны [тут](https://drive.google.com/file/d/1sjHM0QuGODmcs7eYWlwd9_KFZZo-O9Wt/view?usp=sharing).

Е-мейл для связи: nukkduko@gmail.com
