gulp = require("gulp")
livereload = require("gulp-livereload")
nodemon = require("nodemon")
coffee = require("gulp-coffee")
dream = require("gulp-dream")
watch = require("gulp-watch")
clean = require('gulp-clean')
beautify = require('gulp-beautify')

gutil = require('gulp-util')

require "coffee-script/register"

gulp.task "watch", ->
  watch([ "src/**/*.dream" ])
    #.pipe(dream().on("error", gutil.log))
    .pipe(dream())
    .on "error", gutil.log
    .pipe(beautify())
    .pipe(gulp.dest("./dist"))
    #.on "error", (err) -> console.log err

  watch([ "src/**/*.coffee" ])
    #.pipe(coffee(bare: true).on("error", gutil.log))
    .pipe(coffee(bare: true))
    .on "error", gutil.log
    .pipe(gulp.dest("./dist"))

  watch(["src/**/*.{html,css}"]).pipe(gulp.dest("dist"))
  gulp.watch [ "**/*.{html,css,js}" ], cwd: "dist/client", livereload.changed

gulp.task "default", ["watch"], ->
  livereload.listen()
  nodemon( script: "dist/server.js",ignore: ["dist/assets","src/client"], restartable:false)#, stdin:false,stdout:false )
    .on "start", -> console.log "server started."
    .on "restart", -> console.log "server restarted."

gulp.task "repl", ["watch"], ->
  nodemon( script: "dist/repl.js",ignore: ["dist/assets","src/client"], restartable:false )
    .on "start", -> console.log "repl started."
    .on "restart", -> console.log "repl restarted."

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
