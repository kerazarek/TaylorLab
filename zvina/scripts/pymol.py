#!/usr/bin/env python

### Create PyMOL session using docking object data
  #
  # (c) Zarek Siegel
  # created 2016/03/28
  #

from pymol import cmd, stored

class PyMOLObject:
	def load(self):
		# cmd.load( filename [,object [,state [,format [,finish [,discrete [,multiplex ]]]]]] )
		cmd.load(self.pdb_file, self.name)

	def hide

	def show(self, only=True, label=False,
			sticks=True, lines=False, surface=False,
			spheres=False, mesh=False, cartoon=False):
		if only: self.hide_all()
		# cmd.show( string representation="", string selection="" )

		representations = [label, sticks, lines, surface, spheres, mesh, cartoon]
		for representation in representations:
			if representation:
				cmd.show


def main():
	pass

# if __name__ == "__main__": main()
cmd.extend("zvina", main)
