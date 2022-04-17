# minis
Useful collection of tools to make my life easier

**DOS_Plotter**

This script plots density of states from a vasprun.xml file. It can be run in terminal using the following syntax

```
$ python3 ~/path/to/function/DOS_plotter.py plotDOS ~/path/to/vasprun.xml
```

You will be prompted to enter whichever ion you are interested in plotting. Afterwards, a browser window will open with an interactive plot of your density of states. You may zoom using click and drag, you can return to full width of the plot by double clicking the backgroud, you can remove data series by clicking on the legend entry of the orbital you wish to remove, and you can display only a particular orbital of interest by double clicking the legend entry of the orbital you wish to isolate. 

Another function has the same functionality but groups the orbitals by orbital type, rather than by $m_l$ values. This can be done with the following

```
$ python3 ~/path/to/function/DOS_plotter.py plotDOS_sepl ~/path/to/vasprun.xml
```

*Dependencies*

There are quite a few dependencies, but most are common, if not essential

- matplotlib
- numpy
- pandas
- plotly
- elementpath
- sys