gulp = require("gulp")
livereload = require("gulp-livereload")
nodemon = require("nodemon")
coffee = require("gulp-coffee")
watch = require("gulp-watch")
sourcemaps = require("gulp-sourcemaps")
rename = require("gulp-rename")
clean = require('gulp-clean')

source = require('vinyl-source-stream')
gutil = require('gulp-util')

require "coffee-script/register"

gulp.task "default", ->
    livereload.listen()


    watch([ "src/client/**/*.coffee" ])
        #.pipe(coffee(bare: true))
        .pipe(coffee(bare: true).on("error", gutil.log))
        .pipe(gulp.dest("./dist/assets"))
        .on "error", (err) ->
            console.log err

    watch([ "src/**/*.coffee","!src/client" ])
        #.pipe(coffee(bare: true))
        .pipe(coffee(bare: true).on("error", gutil.log))
        .pipe(gulp.dest("./dist"))
        .on "error", (err) ->
            console.log err

    watch(["src/client/**/*.{html,css}"]).pipe(gulp.dest("dist/assets"))

    gulp.watch [ "**/*.{html,css,js}" ], cwd: "dist/assets", livereload.changed

gulp.task "repl", ["default"], ->
    nodemon( script: "dist/repl.js",ignore: ["dist/assets","src/client"], restartable:false )
        .on "start", -> console.log "server started."
        .on "restart", -> console.log "server restarted."
gulp.task "server", ["default"], ->
    nodemon( script: "dist/server.js",ignore: ["dist/assets","src/client"], restartable:false)#, stdin:false,stdout:false )
        .on "start", -> console.log "server started."
        .on "restart", -> console.log "server restarted."

gulp.task "clean", ->
    gulp.src("dist", read:false)
        .pipe(clean(force: true))
gulp.task "build", ["clean"], ->
    gulp.src("src/client/**/*.coffee")
        .pipe(coffee(bare: true).on("error", gutil.log))
        .pipe(gulp.dest("./dist/assets"))
    gulp.src([ "src/**/*.coffee","!src/client/", "!src/client/**" ])
        .pipe(coffee(bare: true).on("error", gutil.log))
        .pipe(gulp.dest("./dist"))
    gulp.src(["src/client/**/*.{html,css}"]).pipe(gulp.dest("dist/assets"))
