import numpy as np
import matplotlib
import matplotlib.pyplot as plt
import matplotlib.axes
import networkx as nx


matplotlib.use("kitcat")


def main():
    AA = np.array(
        [
            [0, 1, 0, 1],
            [1, 0, 1, 0],
            [0, 1, 0, 1],
            [1, 0, 1, 0],
        ]
    )
    G = nx.from_numpy_array(AA)
    fig, ax1 = plt.subplots(
        1,
        1,
        # figsize=(30, 15),
    )
    nx.draw_networkx(G, ax=ax1)  # pos=nx.planar_layout(G1))
    plt.show()


main()

"""
sdf
"""


def main2():
    """
    sdf
    """
    AA = np.array(
        [
            [0, 1, 0, 0, 1, 0, 0],
            [1, 0, 0, 0, 1, 0, 0],
            [0, 1, 0, 1, 0, 0, 0],
            [0, 0, 1, 0, 1, 0, 0],
            [1, 1, 0, 0, 0, 1, 0],
            [0, 0, 0, 0, 1, 0, 0],
            [0, 0, 0, 1, 0, 0, 0],
        ]
    )
    G = nx.from_numpy_array(AA)

    mapping = {0: 4, 1: 5, 2: 6, 3: 2, 4: 0, 5: 1, 6: 3}
    G_prime = nx.relabel_nodes(G, mapping)
    A = nx.to_numpy_array(G, nodelist=np.arange(0, 7))
    A_prime = nx.to_numpy_array(G_prime, nodelist=np.arange(0, 7))

    P = np.array(
        [
            [0, 0, 0, 0, 1, 0, 0],
            [0, 0, 0, 0, 0, 1, 0],
            [0, 0, 0, 0, 0, 0, 1],
            [0, 0, 1, 0, 0, 0, 0],
            [1, 0, 0, 0, 0, 0, 0],
            [0, 1, 0, 0, 0, 0, 0],
            [0, 0, 0, 1, 0, 0, 0],
        ]
    )

    print(f"A = {A}")
    print(f"PAP^T{P.T @ A @ P}")
    print(f"A' = {A_prime}")
    print(f"A' = {np.allclose(A_prime, P.T @ A @ P)}")

    adj_matrix = np.array(
        [
            [0, 1, 0, 0, 1, 0, 0],
            [1, 0, 0, 0, 1, 0, 0],
            [0, 1, 0, 1, 0, 0, 0],
            [0, 0, 1, 0, 1, 0, 1],
            [1, 1, 0, 0, 0, 1, 0],
            [0, 0, 0, 0, 1, 0, 0],
            [0, 0, 0, 1, 0, 0, 0],
        ]
    )

    G2 = nx.from_numpy_array(adj_matrix, create_using=nx.MultiGraph)

    permuted = np.array(
        [
            [0, 1, 0, 0, 1, 1, 0],
            [1, 0, 0, 0, 0, 0, 0],
            [1, 0, 0, 1, 0, 0, 1],
            [0, 0, 1, 0, 0, 0, 1],
            [1, 0, 0, 0, 0, 1, 0],
            [1, 0, 0, 0, 1, 0, 1],
            [0, 0, 1, 0, 0, 1, 0],
        ]
    )

    G3 = nx.from_numpy_array(permuted)

    fig, [ax1, ax2, ax3] = plt.subplots(
        1,
        3,
        figsize=(30, 15),
    )
    labels = {}
    labels[0] = r"$a$"
    labels[1] = r"$b$"
    labels[2] = r"$c$"
    labels[3] = r"$d$"
    labels[4] = r"$\alpha$"
    labels[5] = r"$\beta$"
    labels[6] = r"$\gamma$"
    labels[7] = r"$\delta$"
    nx.draw_networkx(G, ax=ax1)  # pos=nx.planar_layout(G1))
    nx.draw_networkx(G2, ax=ax2)  # pos=nx.planar_layout(G2))
    nx.draw_networkx(G3, ax=ax3)  # pos=nx.planar_layout(G3))
    plt.show()
