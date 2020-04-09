#!/bin/sh

create_package_folders () {
   local LDIR=$1
   local LSRC_DIR=$2
	#echo "Createting Package $1"
   if [ `dirname $LDIR` != "." ]
   then
      echo "create_package_folders $LDIR"
      create_package_folders `dirname $LDIR` $LSRC_DIR
   fi
   echo "Creating directory $LDIR" 
   mkdir -p $LSRC_DIR/$LDIR
}


if [ $# -ne 2 ]
then
	echo "Usage $0 PROJ package"
else
	PROJ=$1
	PKG=$2
   SRC_DIR=$PROJ/src/main/scala
	mkdir -p $SRC_DIR
	if [ $? -eq 0 ]
	then
		## Create the build.sbt file
		echo "Created Directory $PROJ"
		echo "name := \"$PROJ\"" > $PROJ/build.sbt
      echo "version := \"0.1\"" >> $PROJ/build.sbt
		echo "scalaVersion := \"2.11.12\"" >> $PROJ/build.sbt
      echo "// https://mvnrepository.com/artifact/org.apache.spark/spark-core" >>$PROJ/build.sbt
		echo "libraryDependencies += \"org.apache.spark\" %% \"spark-core\" % \"2.3.2\"" >> $PROJ/build.sbt
		## Create the package folders
      DIR=`echo $PKG | tr "." "/"`
      echo "Creating package $PKG $DIR" 
      create_package_folders $DIR $SRC_DIR
		## Create the Scala source file
      SRC_FILE=$SRC_DIR/$DIR/$PROJ.scala
      echo "package $PKG" > $SRC_FILE
      echo "import org.apache.log4j._" >> $SRC_FILE
      echo "import org.apache.spark._" >> $SRC_FILE
      echo "import org.apache.hadoop.conf.Configuration;" >> $SRC_FILE
      echo "import org.apache.hadoop.fs.FileSystem;" >> $SRC_FILE
      echo "import org.apache.hadoop.fs.Path;" >> $SRC_FILE
      echo "import java.io.PrintWriter;" >> $SRC_FILE
      echo "object $PROJ {" >> $SRC_FILE
      echo "  def main(args : Array[String]) {" >> $SRC_FILE
      echo "    Logger.getLogger(\"org\").setLevel(Level.ERROR)" >> $SRC_FILE
      echo "    val sc = new SparkContext(\"local[*]\", \"TestFileWrite\")" >> $SRC_FILE
      echo "    println( \"Trying to write to HDFS...\" )" >> $SRC_FILE
      echo "    val conf = new Configuration()" >> $SRC_FILE
      echo "    conf.set(\"fs.defaultFS\", \"hdfs://192.168.2.184:8020\")" >> $SRC_FILE
      echo "    val fs= FileSystem.get(conf)" >> $SRC_FILE
      echo "    val output = fs.create(new Path(\"/tmp/mySample.txt\"))" >> $SRC_FILE
      echo "    val writer = new PrintWriter(output)" >> $SRC_FILE
      echo "    try {" >> $SRC_FILE
      echo "        writer.write(\"this is a test 1\")" >> $SRC_FILE
      echo "        writer.write(\"\\\n\")" >> $SRC_FILE
      echo "    }" >> $SRC_FILE
      echo "    finally {" >> $SRC_FILE
      echo "        writer.close()" >> $SRC_FILE
      echo "        println(\"Closed!\")" >> $SRC_FILE
      echo "    }" >> $SRC_FILE
      echo "    println(\"Done!\")" >> $SRC_FILE
      echo "  }" >> $SRC_FILE
      echo "}" >> $SRC_FILE
	else
		echo "Failed to create directory $PROJ"
	fi
	echo "Good"
fi
