# US Tree Dashboard Environment Setup

These steps set up the **us-tree-dashboard** repository for local development and testing.

## 1. Clone the repository
```bash
git clone https://github.com/kakashi3lite/us-tree-dashboard
cd us-tree-dashboard
```

## 2. Configure environment variables
Copy `.env.example` to `.env` and add your `OPENAI_API_KEY` along with any other required values.

## 3. Install dependencies
Create a Python 3.11 virtual environment and install the required packages:
```bash
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt pytest-cov openai
```

## 4. Run the tests
```bash
python -m pytest
```

All tests should succeed once dependencies are installed and code fixes are applied.
