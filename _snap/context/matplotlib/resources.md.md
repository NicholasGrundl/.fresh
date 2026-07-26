# Resources

Use these links to parts of the documentastion as a starting point

Plot Types: https://matplotlib.org/stable/plot_types/index

Using Matplotlib: https://matplotlib.org/stable/users/index

Tutorials: https://matplotlib.org/stable/tutorials/index

Examples: https://matplotlib.org/stable/gallery/index

API reference: https://matplotlib.org/stable/api/index


# Guidelines

Matplotlib has two main API interfaces, the Axes interface and the pyplot interface.

We prefer to use the axes interface where possible as it is easier to script and customize.

Our general pattern is:

```
def create_figure():
    # Create figure and manage auto display
    fig, ax = plt.subplots()
    plt.close()

    # Assemble data and add to axes
    x = ...
    y = ...
    ax.plot(x, y, label='data')

    # Style and customize axes
    ax.set_ylabel('Y axis')
    ax.set_title("Sample plot")

    # Other figure level styling
    ax.legend(
        title='Fruit color', bbox_to_anchor=(1,0.5),
        loc='center left',
    )

    #return the figure
    return fig
```
