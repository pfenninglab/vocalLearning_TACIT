import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
from scipy.stats import ranksums
import argparse

if __name__ == '__main__':
	parser = argparse.ArgumentParser()
	parser.add_argument('--d1', required=True)
	parser.add_argument('--d2', required=True)
	parser.add_argument('--output', required=True)
	
	args = parser.parse_args()
	df1 = pd.read_csv(args.d1)
	df2 = pd.read_csv(args.d2)

	plt.rcParams["figure.figsize"] = (15,6)
	sns.histplot(data=df1, x = "Exp_Pvalue", stat='probability',color="lightskyblue", alpha=0.5,bins=25,kde = True, label="near")
	sns.histplot(data=df2, x = "Exp_Pvalue",  stat='probability',color="tan", alpha=0.5,bins=25,kde = True, label="rest")
	plt.legend()
	plt.savefig(args.output)

	res = ranksums(df1.Exp_Pvalue, df2.Exp_Pvalue, alternative='less')
	print(res)