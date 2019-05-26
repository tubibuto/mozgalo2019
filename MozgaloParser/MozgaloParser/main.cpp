// main.cpp : This file contains the 'main' function. Program execution begins and ends there.
//

#include "pch.h"
#include <iostream>
#include <fstream>
#include <ctime>
#include <string>
#include <vector>
#include <utility>
#include <algorithm>
#include <unordered_map>
#include <chrono>

int rdn (int y, int m, int d) { /* Rata Die day one is 0001-01-01 */
	if (m < 3) {
		y--;
		m += 12;
	}
	return 365 * y + y / 4 - y / 100 + y / 400 + (153 * m - 457) / 5 + d - 306;
}

struct sample {
	int id;
	int instanceId;

	int datumIzvjestavanja;
	long long klijentId;
	long long oznakaPartije;
	int datumOtvaranja;
	int planiraniDatumZatvaranja;
	int datumZatvaranja;
	float ugovoreniIznos;
	int valuta;
	float stanjePrethodniKvartal;
	float stanjeKvartal;
	int vrstaKlijenta;
	std::string proizvod;
	char vrstaProizvoda;
	float visinaKamate;
	char tipKamate;
	int starost;
	char prijevremeniRaskid;

	sample () {}
	sample (const std::string& str, const char delim = ',') {
		std::size_t curr = str.find (delim);
		std::size_t prev = 0;
		id = stoi (str.substr (prev, curr - prev));

		prev = curr + 1;
		curr = str.find (delim, prev);
		instanceId = stoi (str.substr (prev, curr - prev));

		prev = curr + 1;
		curr = str.find (delim, prev);
		datumIzvjestavanja = dateToInt (str.substr (prev, curr - prev));

		prev = curr + 1;
		curr = str.find (delim, prev);
		klijentId = stoll (str.substr (prev, curr - prev));

		prev = curr + 1;
		curr = str.find (delim, prev);
		oznakaPartije = stoll (str.substr (prev, curr - prev));

		prev = curr + 1;
		curr = str.find (delim, prev);
		datumOtvaranja = dateToInt (str.substr (prev, curr - prev));

		prev = curr + 1;
		curr = str.find (delim, prev);
		planiraniDatumZatvaranja = dateToInt (str.substr (prev, curr - prev));

		prev = curr + 1;
		curr = str.find (delim, prev);
		datumZatvaranja = dateToInt (str.substr (prev, curr - prev));

		prev = curr + 1;
		curr = str.find (delim, prev);
		ugovoreniIznos = stof (str.substr (prev, curr - prev));

		prev = curr + 1;
		curr = str.find (delim, prev);
		std::string kv = str.substr (prev, curr - prev);
		stanjePrethodniKvartal = kv.size () > 0 ? stof (kv) : 0;

		prev = curr + 1;
		curr = str.find (delim, prev);
		stanjeKvartal = stof (str.substr (prev, curr - prev));

		prev = curr + 1;
		curr = str.find (delim, prev);
		valuta = stoi (str.substr (prev, curr - prev));

		prev = curr + 1;
		curr = str.find (delim, prev);
		vrstaKlijenta = stoi (str.substr (prev, curr - prev));

		prev = curr + 1;
		curr = str.find (delim, prev);
		proizvod = str.substr (prev, curr - prev);

		prev = curr + 1;
		curr = str.find (delim, prev);
		vrstaProizvoda = str.substr (prev, curr - prev) [0];

		prev = curr + 1;
		curr = str.find (delim, prev);
		std::string kam = str.substr (prev, curr - prev);
		visinaKamate = kam.size () > 0 ? stof (kam) : -1;

		prev = curr + 1;
		curr = str.find (delim, prev);
		tipKamate = str.substr (prev, curr - prev) [0];

		prev = curr + 1;
		curr = str.find (delim, prev);
		starost = stoi (str.substr (prev, curr - prev));

		prev = curr + 1;
		curr = str.find (delim, prev);
		prijevremeniRaskid = str.substr (prev, curr - prev) [0];
	}

private:
	int dateToInt (const std::string& date) {
		if (date.size () == 0 || date == "") {
			return -1;
		}

		return rdn (
			stoi (date.substr (6, 4)),
			stoi (date.substr (3, 2)),
			stoi (date.substr (0, 2))) - epoch;
	}

	static int epoch;
};

int sample::epoch = rdn (1970, 1, 1);

int main () {
	/* write you input file name in here */
	std::cout << "Opening input file... ";
	auto start = std::chrono::steady_clock::now ();
	std::ifstream infile ("D:/Mozgalo2019/training_dataset_enc.csv");
	std::string str (200, ' ');
	auto end = std::chrono::steady_clock::now ();
	std::cout
		<< std::chrono::duration_cast<
		std::chrono::milliseconds>(end - start).count ()
		<< "ms"
		<< std::endl;

	// count number of samples in file
	std::cout << "Counting number of samples... ";
	start = std::chrono::steady_clock::now ();
	int count =
		std::count (
			std::istreambuf_iterator<char> (infile),
			std::istreambuf_iterator<char> (),
			'\n') - 1;
	end = std::chrono::steady_clock::now ();
	std::cout
		<< std::chrono::duration_cast<
		std::chrono::seconds>(end - start).count ()
		<< "s"
		<< std::endl;

	// first row of file must have number of samples for optimization reasons
	std::cout << "Reserving memory for sample vector... ";
	start = std::chrono::steady_clock::now ();
	std::vector<sample> samples (count);
	end = std::chrono::steady_clock::now ();
	std::cout
		<< std::chrono::duration_cast<
		std::chrono::milliseconds>(end - start).count ()
		<< "ms"
		<< std::endl;

	// populating samples vector
	// we do this 2 dummy getline() calls to skip file header
	std::cout << "Populating sample vector... ";
	start = std::chrono::steady_clock::now ();
	infile.clear ();
	infile.seekg (0);
	count = 0;
	std::getline (infile, str, '\n');
	while (infile >> str) {
		samples [count++] = sample (str);
	}
	infile.close ();
	end = std::chrono::steady_clock::now ();
	std::cout
		<< std::chrono::duration_cast<
		std::chrono::seconds>(end - start).count ()
		<< "s"
		<< std::endl;

	// sorting data by datum_izvjestavanja
	std::cout << "Sorting fetched data...";
	start = std::chrono::steady_clock::now ();
	std::sort (
		samples.begin (),
		samples.end (),
		[] (sample& s1, sample& s2) {
		if (s1.oznakaPartije < s2.oznakaPartije) {
			return true;
		} else if (s1.oznakaPartije > s2.oznakaPartije) {
			return false;
		} else {
			return s1.datumIzvjestavanja < s2.datumIzvjestavanja;
		}
	});
	end = std::chrono::steady_clock::now ();
	std::cout
		<< std::chrono::duration_cast<
		std::chrono::milliseconds>(end - start).count ()
		<< "ms"
		<< std::endl;

	// here we filter by oznaka_partije so that we take the one where 
	// datum_zatvaranja is lowest and not NaN
	std::cout << "Filtering fetched data... ";
	start = std::chrono::steady_clock::now ();
	std::unordered_map<int, sample*> oznake;
	for (auto& s : samples) {
		if (oznake.find (s.oznakaPartije) == oznake.end ()) {
			oznake [s.oznakaPartije] = &s;
			continue;
		}
		if (oznake [s.oznakaPartije]->datumZatvaranja > -1) {
			continue;
		}
		if (s.datumZatvaranja == -1) {
			continue;
		}
		oznake [s.oznakaPartije]->planiraniDatumZatvaranja = s.planiraniDatumZatvaranja;
		oznake [s.oznakaPartije]->datumZatvaranja = s.datumZatvaranja;
	}
	end = std::chrono::steady_clock::now ();
	std::cout
		<< std::chrono::duration_cast<
		std::chrono::milliseconds>(end - start).count ()
		<< "ms"
		<< std::endl;

	// writing into result file
	// we use buffer because we don't want to call write method for each row
	/* write you result file name in here */
	std::cout << "Writing into output file... ";
	start = std::chrono::steady_clock::now ();
	std::ofstream outfile ("D:/Mozgalo2019/training_dataset_filtered_3.csv");
	outfile
		<< "KLIJENT_ID,OZNAKA_PARTIJE,DATUM_OTVARANJA,PLANIRANI_DATUM_ZATVARANJA,"
		<< "DATUM_ZATVARANJA,UGOVORENI_IZNOS,VALUTA,VRSTA_KLIJENTA,"
		<< "PROIZVOD,VRSTA_PROIZVODA,VISINA_KAMATE,TIP_KAMATE,STAROST,"
		<< "PRIJEVREMENI_RASKID"
		<< std::endl;
	int thr = 64000;
	std::string buffer;
	buffer.reserve (thr + 1000);
	for (const auto& oznaka : oznake) {
		if (buffer.length () > thr) {
			outfile << buffer;
			buffer.resize (0);
		}
		buffer.append (std::to_string (oznaka.second->klijentId));
		buffer.append (",");
		buffer.append (std::to_string (oznaka.second->oznakaPartije));
		buffer.append (",");
		buffer.append (
			oznaka.second->datumOtvaranja != -1 ?
			std::to_string (oznaka.second->datumOtvaranja) :
			"");
		buffer.append (",");
		buffer.append (
			oznaka.second->planiraniDatumZatvaranja != -1 ?
			std::to_string (oznaka.second->planiraniDatumZatvaranja) :
			"");
		buffer.append (",");
		buffer.append (
			oznaka.second->datumZatvaranja != -1 ?
			std::to_string (oznaka.second->datumZatvaranja) :
			"");
		buffer.append (",");
		buffer.append (std::to_string (oznaka.second->ugovoreniIznos));
		buffer.append (",");
		buffer.append (std::to_string (oznaka.second->valuta));
		buffer.append (",");
		buffer.append (std::to_string (oznaka.second->vrstaKlijenta));
		buffer.append (",");
		buffer.append (oznaka.second->proizvod);
		buffer.append (",");
		buffer.append (std::string (1, oznaka.second->vrstaProizvoda));
		buffer.append (",");
		buffer.append (
			oznaka.second->visinaKamate != -1 ?
			std::to_string (oznaka.second->visinaKamate) :
			"");
		buffer.append (",");
		buffer.append (std::string (1, oznaka.second->tipKamate));
		buffer.append (",");
		buffer.append (std::to_string (oznaka.second->starost));
		buffer.append (",");

		char prijevremeniRaskid =
			oznaka.second->planiraniDatumZatvaranja > -1 &&
			oznaka.second->datumZatvaranja > -1 &&
			oznaka.second->datumZatvaranja + 10 <
			oznaka.second->planiraniDatumZatvaranja ?
			'Y' :
			'N';
		buffer.append (std::string (1, prijevremeniRaskid));
		buffer.append ("\n");
	}
	outfile << buffer;
	outfile.close ();
	end = std::chrono::steady_clock::now ();
	std::cout
		<< std::chrono::duration_cast<
		std::chrono::seconds>(end - start).count ()
		<< "s"
		<< std::endl;

	std::cout << std::endl << "Done" << std::endl;
	std::getchar ();
}
