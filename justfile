set positional-arguments

default := 'default'

stl model=default :
  openscad -v
  @echo 'Making stl of model with {{model}} settings'
  openscad -o chave-seg-{{model}}.stl -p chave-seg.json -P {{model}} chave-seg.scad
