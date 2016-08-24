DoBo: Protein Domain Boundary Prediction by Integrating Evolutionary Signals and Machine Learning
8/15/2016

Web-server
----------
http://sysbio.rnet.missouri.edu/dobo/

Installation
------------
(1) Download 'dobo.zip', 'models.zip', 'programs.zip', and 'db.zip' into a folder
    Download URL: http://sysbio.rnet.missouri.edu/bdm_download/dobo/downloads/
    $ mkdir dobo
    $ cd dobo 
(2) Unzip the files
    $ unzip dobo.zip
    $ unzip db.zip
    $ unzip programs.zip
    $ unzip models.zip
(3) Verify that the following files folders and files are present
    (a) bin/, lib/, sample/, scripts/, old_readme.pdf, readme.txt (this file)
    (b) programs/
    (c) db/
(4) Configure SSPro
    Update all the 'install dir' and 'db dir' in 'programs/sspro4.1/configure.pl' and run SSPro configuration
    $ cd ./programs/sspro4.1/
    $ ./configure.pl
(5) Update the paths for SCRIPT_DIR, PROGRAM_DIR, MODELS_DIR, and LD_LIBRARY_PATH in the following scripts
    (a) bin/run-dobo-stage1.sh
    (b) bin/run-dobo-stage2.sh
    For eg. sed -i "s/\/rose\/space1\/bap54\/temp\/dobo-share\/programs/\/tmp\/dobo\/programs/g" ./bin/run-dobo-stage1.sh
(6) Update the paths for BLAST_PATH, BLAST_NR_DB, BLASTMAT, CONVERT_PATH in 'scripts/generate-msa.sh'
(7) Test DoBo
    $ ./bin/run-dobo-stage2.sh sample/test.fasta test-stg2.out
(8) Verify the results with the web-server results
    Submit the same sequence into the web-server and ensure that you local results match the web-server results.

Publication
-----------
J. Eickholt, X. Deng, and J. Cheng. DoBo: Protein Domain Boundary Prediction by 
Integrating Evolutionary Signals and Machine Learning. BMC Bioinformatics. 12:43, 2011.

Contact
-------
Prof. Jianlin Cheng
chengji@missouri.edu