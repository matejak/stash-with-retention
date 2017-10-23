# stash-with-retention

This project provides a very simple way how to manage backups.
It consists of a bash library and a script which provides a simple interface to it.

## Storage schema

Consider a situation when you make database backups by dumping them in `.sql` files every day.
Then, you want to keep one month of daily backups and one year of monthly backups.
Those backups will have to have a filename that has a property that sorting backups lexicographically is the same as sorting them time-wise - e.g. `backup-2017-03-26.sql.gz`.

In order to control the backup, you have to set up two directories:

* `shortterm`, where the daily backups will be copied, and
* `longterm`, where the monthly backups will reside.

Then, you ensure that the `apply-retention` script is executed in a way that both `shortterm` and `longterm` are subdirectories of the working directory.
By calling it `./apply-retention -s -31 -l 12 -r '-01\.sql'`, you tell it to keep at most 31 files in the `shortterm` directory.
Excess files will be either moved to the `longterm` directory (if they match the system's `grep` regular expression specified as argument), or they will be deleted.

## Caveats

* The script doesn't know anything of time - it just deals with filenames.
* Non-alphanumeric characters may not be handled correctly (however spaces in filenames are OK).
* If a backup doesn't arrive on a day that corresponds to the longterm regular expression, it will not be copied to the `longterm` directory. This means that if you miss one daily backup, you may actually miss one monthly backup as a side-effect.

## Vision

A container that accepts SFTP connections and stores a limited number of data that arrive.

### Configuration

* The shortterm, longterm storage quota.
* The SSH public key.
* File patterns?
