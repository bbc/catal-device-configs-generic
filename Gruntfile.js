/* jshint node: true */

module.exports = function (grunt) {
	"use strict";

	grunt.initConfig({
		pkg: grunt.file.readJSON("package.json"),
        jsonlint: {
            sample: {
                src: [ 'compiled/*.json' ]
            }
        }
	});

    grunt.loadNpmTasks('grunt-jsonlint');
};
