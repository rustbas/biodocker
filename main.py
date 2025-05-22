from pysam import Fastafile
from sys import argv, stderr, stdout
import argparse
import logging
import os

format_header = "#CHROM\tPOS\tID\tREF\tALT"
format_line = "{chrom}\t{pos}\t{rs}\t{ref}\t{alt}"
warning_string = "Can't locate nucleotid \
{ref} in reference ({nucl}), chrom:{chrom:>6s}, pos:{pos}"


# TODO: Fill usage and description
DESCRIPTION="""

"""

parser = argparse.ArgumentParser(description=DESCRIPTION)
parser.add_argument('-i', '--input-file',
                    type=str,
                    required=True,
                    help="VCF-like file, which need to be analysed")
parser.add_argument('-o', '--output-file',
                    type=str,
                    default="stdout",
                    help="Result file (default: stdout)")
parser.add_argument('-l', '--log-file',
                    type=str,
                    default="stderr",
                    help="Log-file (default: stderr)")
parser.add_argument('-r', '--reference',
                    type=str,
                    required=True,
                    help="Reference file")
parser.add_argument('--index-file',
                    type=str,
                    default=None,
                    help="Reference index file (default: [REFERENCE FILE].fai)")
namespace = parser.parse_args()

if namespace.log_file == "stderr":
    logging.basicConfig(level=logging.INFO, stream=stderr,
                        format="%(asctime)s %(levelname)s %(message)s")
elif namespace.log_file == "stdout": 
    logging.basicConfig(level=logging.INFO, stream=stdout,
                        format="%(asctime)s %(levelname)s %(message)s")   
else:
    logging.basicConfig(level=logging.INFO, filename=namespace.log_file,
                        filemode="a",
                        format="%(asctime)s %(levelname)s %(message)s")

INPUT_FILE = namespace.input_file
OUTPUT_FILE = namespace.output_file
REFERENCE_FILE = namespace.reference
if (namespace.index_file is None):
    INDEX_FILE = REFERENCE_FILE + ".fai"
else:
    INDEX_FILE = namespace.index_file

if OUTPUT_FILE != "stdout":
    result_data = []

if not os.path.exists(INPUT_FILE):
    logging.error(f"No such file or directory: '{INPUT_FILE}'")
    exit(1)

# TODO: add output file if needed
with Fastafile(filename=REFERENCE_FILE, filepath_index=INDEX_FILE) as fasta, \
     open(INPUT_FILE, "r") as file:
    
    header = file.readline().strip().split('\t')
    logging.info(f'Readed header: {header}')
    if len(header) != 5:
        n = len(header)
        logging.error(f"Expected 5 columns in header, got {n}")
        exit(1)
    if OUTPUT_FILE == "stdout":
        print(format_header)
    for line in file.readlines()[:]:
        chrom, pos, rs, ref, alt = line.strip().split('\t')
        pos = int(pos) - 1 # In PySam 'start' is 0-based
        nucleotid_in_fasta = fasta.fetch(reference=chrom, start=pos, end=pos+1)

        # Set REF as in FASTA file
        if alt == nucleotid_in_fasta:
            ref, alt = alt , ref

        # Log if REF and ALT not as in FASTA file
        if ref != nucleotid_in_fasta:
            warning = warning_string.format(ref=ref,
                                            nucl=nucleotid_in_fasta,
                                            chrom=chrom,
                                            pos=pos)
            logging.warning(warning) # Log
            continue

        newline = format_line.format(chrom=chrom,
                                     pos=pos,
                                     rs=rs,
                                     ref=ref,
                                     alt=alt)

        if OUTPUT_FILE == "stdout":
            print(newline)
        else:
            result_data.append(
                newline
            )

if OUTPUT_FILE != "stdout":
    with open(OUTPUT_FILE, "w") as file:
        # Hack with newline because "writelines" actually write ONE line
        file.writelines(format_header + "\n")
        file.writelines(line + "\n" for line in result_data)
