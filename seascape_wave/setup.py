#!/usr/bin/env python3

from setuptools import setup, find_packages

setup(
    name="Seascape Wave",
    version="0.1",
    packages=find_packages(),
    include_package_data=True,

    author="David Visscher, Wiebe-Marten Wijnja",
    author_email="pypi-dev@davidvisscher.nl",
    description="Monitoring agent for seascape.",
    keywords="seascape agent monitoring",

    python_requires='>=3.8',

    install_requires=[
        "click==7.1.2",
        "salt==3001.1"
    ]

    entry_points='''
        [console_scripts]
        ss_agent=ss_wave:main
    '''
)
