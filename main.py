from pysam import Fastafile, VariantFile

INPUT_FILE = "FP_SNPs_10k_GB38_twoAllelsFormat.tsv"

data = []
with open(INPUT_FILE, "r") as f:
    header = f.readline().strip().split('\t')
    for line in f.readlines():
        data.append(line.strip().split('\t'))

print(header)
for d in data[:5]:
    print(d)

vcf = VariantFile(INPUT_FILE)
