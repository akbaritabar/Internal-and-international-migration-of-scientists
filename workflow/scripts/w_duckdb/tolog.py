# ============================
#### Results log and progress report ####
# ============================

# to keep record of events
import logging

# save log report here
logging.basicConfig(level=logging.INFO,
     format="%(asctime)s - %(name)s - %(levelname)s - %(message)s")

# define a shortcut for logging function and its "info" method
lg = logging.info

# this will be imported on the top of other scripts as and function "lg()" will allow logging:
# from tolog import lg
