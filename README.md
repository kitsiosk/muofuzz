# On Interaction Effects in Greybox Fuzzing
This is the replication package for the paper titled "On Interaction Effects in Greybox Fuzzing" that is accepted at ICSE '26.

### Overview
The standalone fuzzer exists under the `muofuzz/` directory. To make the replication of our results easier, we provide the code used for our FuzzBench[1] and MAGMA[2] experiments, under the `fuzzbench/` and `magma/` directories respectively.
Finally, plots and figures that did not fit into the paper can be found under the `assets/` directory.
Specifically, `assets/learned probability/` contains the learned probability for each target program (mentioned in Section 3.1 of the paper) and `assets/magma boxplots` contains one boxplot for each of the 43 MAGMA bugs (mentioned in Section 5.3 of the paper). Note that MuoFuzz is implemented on top of v4.21a of AFL++.

### Standalone Fuzzer
MuoFuzz is an extension of AFL++, so the setup required to run MuoFuzz is the same as AFL++. The folder `muofuzz/` is a fork of the [AFL++ repo](https://github.com/AFLplusplus/AFLplusplus) containing all the necessary instructions to setup and run MuoFuzz, as one would do with AFL++.

### FuzzBench
We provide the code to run our FuzzBench experiments. The folder `fuzzbench/` is a fork of the [FuzzBench repo](https://github.com/google/fuzzbench) enriched with MuoFuzz, as well as the variations we experiment with in the ablation study (see [Ablation Study](#ablation-study) study below).

Refer to `fuzzbench/README.md` for instruction on how setup FuzzBench and prepare the experiments (how to set the fuzzing time limit, where to find the outputs etc).
Then, to run for example MuoFuzz, AFL++, and MOPT in the `proj4_proj_crs_to_crs_fuzzer` target program, run
```sh
PYTHONPATH=. python3 experiment/run_experiment.py --experiment-config experiment-config.yaml --concurrent-builds 8 --benchmarks proj4_proj_crs_to_crs_fuzzer --fuzzers  muofuzz aflplusplus aflplusplus_mopt  --runners-cpus 24 --measurers-cpus 2 --experiment-name myexpname
```

The thirteen benchmarks used in our paper are `proj4_proj_crs_to_crs_fuzzer`, `curl_curl_fuzzer_http`, `freetype2_ftfuzzer`, `bloaty_fuzz_target_52948c`, `php_php-fuzz-parser_0dbedb`, `libxml2_xml_e85b9b`, `sqlite3_ossfuzz`, `libpng_libpng_read_fuzzer`, `libpcap_fuzz_both`, `lcms_cms_transform_fuzzer`, `openssl_x509`, `re2_fuzzer`, `jsoncpp_jsoncpp_fuzzer`.

### MAGMA
We provide the code to run our MAGMA experiments. The folder `magma/` is a fork of the [MAGMA repo](https://github.com/HexHive/magma) enriched with MuoFuzz.

Refer to the [MAGMA docs](https://hexhive.epfl.ch/magma/docs/getting-started.html)  for instruction on how setup MAGMA and prepare the experiments (how to select fuzzers and target programs, where to find the outputs etc).
Note that, some requirements for MAGMA may conflict with some requirements of FuzzBench (e.g. different docker installation). For this reason, we used different machines for the two benchmarks and suggest users to do the same.

Then, to run for example MuoFuzz, AFL++, and MOPT in the `sqlite3` target program, edit the `magma/tools/captain/.captainrc` file as follows
```
[...previous lines here]
FUZZERS=(muofuzz aflplusplus aflplusplus_mopt)

[...other lines here]

muofuzz_TARGETS=(sqlite3)
aflplusplus_TARGETS=(sqlite3)
aflplusplus_mopt_TARGETS=(sqlite3)

[...next lines here]
```
Then, run `cd tools/captain/` and `./start.sh`.
We use all available target programs, found under `magma/targets`.

### Ablation study
Finally, we provide the code to run our Ablation Study experiments (Section 5.4 in the paper) in FuzzBench. For each column of Table 5, we provide a fuzzer in `fuzzbench/fuzzers/` than can be run as described in the [FuzzBench section](#fuzzbench)



### Requirements
All experiments took place in sixteen identical virtual machines (VMs) running
Ubuntu 22.04, each one having an AMD EPYC 7702 processor with 32 CPUs, 125GB of RAM, and 100GB of disk. We restricted experiments of the same target program to the same set of VMs, for example, we use only VM1 and VM2 for the experiments on proj4 to further ensure fairness (although the VMs are identical). Only 24 out of 32 cores (∼ 80 %) are used simultaneously


### References
[1]: Metzman, Jonathan, et al. "Fuzzbench: an open fuzzer benchmarking platform and service." Proceedings of the 29th ACM joint meeting on European software engineering conference and symposium on the foundations of software engineering. 2021.

[2]: Hazimeh, Ahmad, Adrian Herrera, and Mathias Payer. "Magma: A ground-truth fuzzing benchmark." Proceedings of the ACM on Measurement and Analysis of Computing Systems 4.3 (2020): 1-29.